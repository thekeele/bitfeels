# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

Training script for binary text classifier. neutral class added
for accuracy

positive text is given a value of +1
neutral  text is given a value of  0
negative text is given a value of -1

@author: rcehemann
"""
###############################################################################

# logistical stuff
import pandas as pd                                     # pandas allows easy manipulation of the data
import numpy as np                                      # 
from sklearn.feature_extraction.text import CountVectorizer # preprocessor
from sklearn.feature_selection import chi2, SelectKBest # used to filter useless data
from sklearn.pipeline import Pipeline                   # pre-processing pipeline
from sklearn.model_selection import cross_val_score     # for testing accuracy
from sklearn.externals.joblib import dump               # fitted model will be pickled for later use

# classification algorithm
from sklearn.naive_bayes import MultinomialNB # naive bayes classifiers

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
#del amazon, yelp, imdb, uic_pro, uic_con, dz, kaggle_a, kaggle_m

# drop any duplicates and reset index
data.drop_duplicates(inplace=True)
data.reset_index(drop=True, inplace=True)
print(25*'-')
print("training set:")
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
""" this section trains a multinomial naive bayes classifier """
# MultinomialNB is fast and easy so we'll stick to that
# but look for a good smoothing value (alpha hyperparameter) and
# feature size (k). Save best classifier for fitting to whole DB later
best_cvs = 0    # cv score
best_clf = None # classifier

# define generator for pipelines
def MNB_Pipeline(alpha, k):
    # pipeline provides a workflow for processing the input text
    # vect turns strings into sparse arrays of word-counts
    # tfidf scales word counts based on frequency across samples
    # chi2 selects k features based on correlation with target
    # clf takes k-best as input and outputs 1 or 0
    return Pipeline([
            ('vect',    CountVectorizer()),
            ('chi2',    SelectKBest(chi2, k=k)),
            ('clf',     MultinomialNB(alpha=alpha))
    ])

for alpha in np.arange(0.5,1.1,0.1):
    for k in np.arange(2000,15000,1000):
    
        pipeline = MNB_Pipeline(alpha, k)
        # cross-validation splits the data roughly in half, 
        # fits to one half and tests accuracy on the other. 
        CVS = cross_val_score(
            pipeline, 
            data['sentence'], 
            y=data['sentiment'], 
            cv=100
        )
        
        print("alpha = %0.3f, k= %5d, CV accuracy: %0.5f (+/- %0.5f)"
              % (alpha, k, CVS.mean(), CVS.std()*2))
        
        if CVS.mean() > best_cvs:
            best_cvs = CVS.mean()
            best_alpha = alpha
            best_k = k
            best_clf = pipeline
        
# now fit best-performing classifier to entire dataset
print("Best parameters are = %.2f and k = %4d" % (best_alpha, best_k))
pipeline = MNB_Pipeline(best_alpha, best_k)

pipeline.fit(data['sentence'], y=data['sentiment'])

# store the fitted pipeline in binary_classifier.pckl
dump(pipeline, '../model/binary_classifier.pckl')
print("Model stored in ../model/binary_classifier.pckl")
""" all done """

