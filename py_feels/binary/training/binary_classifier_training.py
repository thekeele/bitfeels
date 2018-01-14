# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

Training script for binary text classifier. neutral class added
for accuracy

positive text is given a value of +1
neutral  text is given a value of  0
negative text is given a value of -1

@author: rcehemann

notes and definitions:
----------------------
    'regularization' is the penalization of model coefficients, typically 
    based on an n-norm scalar size, to favor solutions with coefficients
    having similar orders of magnitude. This prevents over-fitting and dominance
    of strong correlations in the fitting data. 'alpha' parameters typically
    represent the multiplicative coefficient to the regularization term in
    the loss (objective for minimization) function
    
    'stop words' are pre-defined useless words which are not included
    in the feature vectors. 'and', 'is', 'are', etc. are examples.
    
    'cross-validation' is the practice of fitting a model to a subset of training
    data and testing accuracy against the held-out data. this is done multiple
    times to assess the over- or under-fitting of a model.

    New models can be added by defining a 'NEW_Pipeline()' function and adding
    a dictionary element with key 'NEW', containing the appropriate model
    parameters, to grid_params. If a list of parameter values is supplied
    a grid search will be performed over all possible combinations and the best
    will be saved.
"""
###############################################################################

# logistical stuff
import pandas as pd                                     # pandas allows easy manipulation of the data
import numpy as np                                      # 
from sklearn.feature_extraction.text import TfidfVectorizer # preprocessor
from sklearn.feature_selection import chi2, SelectKBest # used to filter useless data
from sklearn.pipeline import Pipeline                   # pre-processing pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, GridSearchCV # for testing accuracy
from sklearn.externals.joblib import dump               # fitted model will be pickled for later use
import pickle
# 

# classification algorithms
from sklearn.naive_bayes import MultinomialNB       # naive bayes classifiers
from sklearn.linear_model import LogisticRegression # linear classifier (maximal entropy)
from sklearn.svm import LinearSVC                   # linear support-vector classifier
from sklearn.neural_network import MLPClassifier    # MLP (feed-forward NN) classifier
###############################################################################
#%%
""" this section assembles training data """
# assemble training data from various files into pandas DataFrame objects.
# format of the dataframe is a sentence followed by a sentiment
# 1 == positive sentiment and 0 == neutral and -1 == negative

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# First UCI data from amazon/yelp/imdb
amazon = pd.read_csv(
        'UCI_training_data/amazon_cells_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)
# convert from 1/0 scheme to 1/0/-1 scheme
amazon.sentiment = 2 * amazon.sentiment - 1

yelp   = pd.read_csv(
        'UCI_training_data/yelp_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)
# convert from 1/0 scheme to 1/0/-1 scheme
yelp.sentiment = 2 * yelp.sentiment - 1

imdb   = pd.read_csv(
        'UCI_training_data/imdb_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)
# convert from 1/0 scheme to 1/0/-1 scheme (contains no neutrals)
imdb.sentiment = 2 * imdb.sentiment - 1

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# next read the UIC pros/cons files taken from amazon reviews
uic_pro = pd.read_csv(
        './UIC_pros_cons/IntegratedPros.txt',
        comment=';',
        sep='\n',
        names=['sentence'],
        encoding='ISO-8859-1'
)
uic_pro.dropna(inplace=True) # some lines are read improperly so drop them
uic_pro['sentiment'] = 1

uic_con = pd.read_csv(
        './UIC_pros_cons/IntegratedCons.txt', 
        comment=';',
        sep='\n',
        names=['sentence'],
        encoding='ISO-8859-1'
)
uic_con.dropna(inplace=True) # some lines are read improperly so drop them
uic_con['sentiment'] = -1

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# next read kaggle data for neutral values: first airline tweets
kaggle_a = pd.read_csv(
        './kaggle_airline_tweets/Tweets.csv', 
        usecols=['text', 'airline_sentiment']
)
# rename columns using our scheme and then sort column names
kaggle_a.rename(columns={'text':'sentence', 'airline_sentiment':'sentiment'}, 
              inplace=True)
kaggle_a.sort_index(axis=1)
# data is imbalanced in favor of negative tweets; we already have a nice
# balance of positive and negative from the other data, so we drop everything
# that doesn't have neutral sentiment
kaggle_a = kaggle_a[kaggle_a.sentiment == 'neutral']
kaggle_a.sentiment = 0

# now kaggle movie reviews
kaggle_m = pd.read_csv(
        './kaggle_movie_reviews/train.tsv',
        encoding='ISO-8859-1',
        sep='\t',
        usecols=['Phrase', 'Sentiment'],
)
#  rename to fit scheme and then sort
kaggle_m.rename(columns={'Phrase':'sentence','Sentiment':'sentiment'},
              inplace=True)
kaggle_m.sort_index(axis=1)
# this data is absolute garbage. we will drop all sentences with fewer than
# seven words and everything that isn't neutral
kaggle_m = kaggle_m[kaggle_m.sentiment == 2]
kaggle_m = kaggle_m[kaggle_m['sentence'].apply(lambda x: len(x.split())>6)]
kaggle_m.sentiment = 0

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
# concatenate the individual dataframes, shuffle them 
# (sample with frac=1) and reset the index
data   = pd.concat([amazon, yelp, imdb, uic_pro, uic_con,
                    kaggle_a, kaggle_m],
                   ignore_index = True).sample(frac=1).reset_index(drop=True)
# clean up
del amazon, yelp, imdb, uic_pro, uic_con, kaggle_a, kaggle_m

# drop any duplicates and reset index
data.drop_duplicates(inplace=True)
data.reset_index(drop=True, inplace=True)

print(25*'-')
print("data set:")
print("%7d total instances" % data.shape[0])
print("%.2f %% positive " % (100*sum(data.sentiment ==  1)/data.shape[0]))
print("%.2f %% neutral  " % (100*sum(data.sentiment ==  0)/data.shape[0]))
print("%.2f %% negative " % (100*sum(data.sentiment == -1)/data.shape[0]))
print(25*'-')
print("training...")
"""
     done assembling training data 
     total of 66,286 rows
     22,582 positive (+1)
     22,216 neutral  ( 0)
     21,488 negative (-1)
"""
#%%
""" this section trains a variety of classifiers """

# split into 75% training and 25% testing data. stratify on sentiment
# to keep balance between positive/neutral/negative samples
test_split = 0.25
x_train, x_test, y_train, y_test = train_test_split(data['sentence'],
                                                    data['sentiment'],
                                                    stratify=data['sentiment'],
                                                    test_size=test_split)

# define generators for pipelines
# pipeline provides a workflow for processing the input text
# vect turns strings into sparse arrays of word-counts
# tfidf scales word counts based on frequency across samples
# chi2 selects k features based on correlation with target
# scal, where applied, re-scales the tfidf features to have unit variance
# clf takes k-best as input and outputs 1 or 0
""" Logistic regression is the simplest linear model for classification.
    l1 regularization is reffered to as 'Lasso' regression, and shrinks
    coefficients of unimportant features down to zero. l2 regularization
    is called 'Ridge' regression and favors nearly-equal coefficients """    
def LIN_Pipeline(k=1000, pen='l1'):
    return Pipeline([
            ('vect',    TfidfVectorizer(stop_words='english')),
            ('chi2',    SelectKBest(chi2, k=k)),
            ('clf',     LogisticRegression(multi_class='ovr',
                                           solver='liblinear',
                                           penalty=pen))
    ])
    
""" multinomial naive bayes uses Bayes' theorem with an assumption of 
    independent features (hence naive) satisfying a multinomial distribution """
def MNB_Pipeline(alpha=1.0, k=1000):
    return Pipeline([
            ('vect',    TfidfVectorizer(stop_words='english')),
            ('chi2',    SelectKBest(chi2, k=k)),
            ('clf',     MultinomialNB(alpha=alpha))
    ])

""" Linear support vector classifier locates a decision boundary using
    the 'maximal road width' heuristic. """
def SVC_Pipeline(k=1000):
        return Pipeline([
            ('vect',    TfidfVectorizer(stop_words='english')),
            ('chi2',    SelectKBest(chi2, k=k)),
            ('clf',     LinearSVC(multi_class='ovr'))
        ])

""" Multilayer perceptron (neural network) classifier. sensitive to 
    scaling so uses a normalized feature scaler. L2 regularization
    is enabled by default, but the scikit MLP objects do not support
    dropout so over-fitting can be common. default ReLU activation
    is used with the ADAM optimizer. FYI training MLP with scikit is
    painfully slow."""
def MLP_Pipeline(k=1000, n_hidden=2):
        return Pipeline([
            ('vect',    TfidfVectorizer(stop_words='english')),
            ('scal',    StandardScaler(with_mean=False)),
            ('chi2',    SelectKBest(chi2, k=k)),
            ('clf',     MLPClassifier(hidden_layer_sizes=(100,)))
        ])

# define grid parameters
k_grid = [10000,15000] # k-best selections



# dict of dicts containing sampled values of parameters for each model.
# the prefix clf__ or chi2__ refers to steps in the Pipeline object, and
# the rest of the string refers to a parameter of that step.
grid_params = {
               'LIN':{'chi2__k':k_grid, 
                      'clf__penalty':['l1', 'l2']},
               'MNB':{'chi2__k':k_grid, 
                      'clf__alpha':[0.8, 0.9, 1.0]},
               'SVC':{'chi2__k':k_grid},
               'MLP':{'chi2__k':k_grid,
                      'clf__alpha':[0.5, 1.0, 5.0],
                      'clf__hidden_layer_sizes':[l*tuple([n],)
                                            for n in [100]
                                            for l in [2]]
                      } # only using 25x25 NN for now because it's so slow
}
# loop over defined pipelines to perform 5-fold cross validation for grid search.
# best_estimator_ is refit to the entire training set at the end.
# train and test scores are printed.
               
# print header
print(100*'-')
print("%20s %20s %20s %30s" 
      % ('Classifier', 'Training score', 'Testing score', 'Parameters'))
print(100*'-')

best = {}; params = {}; train_score = {}; test_score = {}; name = {}  
tags = list(grid_params.keys())
for tag in tags:
    grid = GridSearchCV(eval(tag + '_Pipeline()'), grid_params[tag], cv=5)
    grid.fit(x_train, y=y_train)
    best[tag]        = grid.best_estimator_
    name[tag]        = dict(best[tag].steps)['clf'].__class__.__name__
    params[tag] = grid.best_params_
    train_score[tag] = grid.best_score_
    test_score[tag]  = best[tag].score(x_test, y=y_test)
    print("%20s %20.8f %20.8f %30s" % (name[tag],
                                  train_score[tag],
                                  test_score[tag],
                                  params[tag]))
print(100*'-')
print("finished!")
#%%
""" done training, now save models """
# store the fitted pipelines in ../model/ directory.
# a dict containing paths is pickled for reading by predictor script.
save_dict = {}
for tag in tags:
    path = './model/' + name[tag] + '.pckl'
    dump(best[tag], '.' + path) # extra . for ../
    save_dict[name[tag]] = path

with open('../model/model_dict.pckl', 'wb') as f:  
    pickle.dump(save_dict, f)

print("Models stored in ../model/")
""" all done """

