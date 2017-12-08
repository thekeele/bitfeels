# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

Training script for binary text classifier

@author: rcehemann
"""
###############################################################################

# logistical stuff
import pandas as pd                                     # pandas allows easy manipulation of the data
from sklearn.feature_extraction.text import TfidfTransformer, CountVectorizer # preprocessors
from sklearn.feature_selection import chi2, SelectKBest # used to filter useless data
from sklearn.pipeline import Pipeline                   # pre-processing pipeline
from sklearn.model_selection import cross_val_score     # for testing accuracy
from sklearn.externals.joblib import dump               # fitted model will be pickled for later use

# classification algorithms
from sklearn.svm      import SVC                        # support-vector machine classifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier # tree-based classifiers
from sklearn.neural_network import MLPClassifier        # multilayer perceptron classifier (dense NN)
from sklearn.naive_bayes import MultinomialNB           # naive bayes classifier w/ multinomial distribution

###############################################################################


# assemble training data from various files into pandas DataFrame objects.
# format of the files is a sentence followed by a sentiment
# 1 == positive sentiment and 0 == negative sentiment
amazon = pd.read_csv(
        'UCI_training_data/amazon_cells_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)

yelp   = pd.read_csv(
        'UCI_training_data/yelp_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)

imdb   = pd.read_csv(
        'UCI_training_data/imdb_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)

# concatenate the individual dataframes, shuffle them 
# (sample with frac=1) and reset the index
data   = pd.concat([amazon, yelp, imdb], 
                   ignore_index = True).sample(frac=1).reset_index(drop=True)
del amazon, yelp, imdb # clean up

# we loop over a few classifiers looking for a good one. 
# save best classifier for fitting to whole DB later
best_cvs = 0    # cv score
best_clf = None # classifier
for clf in [MultinomialNB(), RandomForestClassifier(), GradientBoostingClassifier()]:

    # pipeline provides a workflow for processing the input text
    # vect turns strings into sparse arrays of word-counts
    # tfidf scales word counts based on frequency across samples
    # chi2 selects k features based on correlation with target
    # clf takes k-best as input and outputs 1 or 0 
    pipeline = Pipeline([
            ('vect',   CountVectorizer()),             
            ('tfidf',  TfidfTransformer()),            
            ('chi2',   SelectKBest(chi2, k=2000)),     
            ('clf',     clf)
    ])                         
    
    # cross-validation splits the data roughly in half, 
    # fits to one half and tests accuracy on the other. 
    CVS = cross_val_score(pipeline, 
                          data['sentence'], 
                          y=data['sentiment'], 
                          cv=100)
    print("%30s cross-validation accuracy: %0.3f (+/- %0.3f)"
          % (clf.__class__.__name__, CVS.mean(), CVS.std()*2))
    
    if CVS.mean() > best_cvs:
        best_cvs = CVS.mean()
        best_clf = clf
        
# now fit best-performing classifier to entire dataset
print("Fitting " + best_clf.__class__.__name__ + " to full dataset")
pipeline = Pipeline([
        ('vect',   CountVectorizer()),
        ('tfidf',  TfidfTransformer()),
        ('chi2',   SelectKBest(chi2, k=2000)),
        ('clf',    best_clf)
])  

pipeline.fit(data['sentence'], y=data['sentiment'])

# store the fitted pipeline in binary_classifier.pckl
dump(pipeline, '../model/binary_classifier.pckl')
print("Model stored in ../model/binary_classifier.pckl")

