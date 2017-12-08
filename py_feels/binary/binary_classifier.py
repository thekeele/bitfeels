# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

Binary sentiment classifier for BitFeels. Loads model fit by
binary_classifier_training.py and produces predictions. Currently
just runs on amazon training data, but will eventually pull from
mongo DB of tweets and return sentiments

@author: rcehemann
"""

# we only need pandas, mongo and joblib to use the model
import pandas as pd
from sklearn.externals.joblib import load

# load fitted model
model = load('./model/binary_classifier.pckl')

# read amazon training data for testing loaded model
amazon = pd.read_csv(
        './training/UCI_training_data/amazon_cells_labelled.txt', 
        sep="\t", 
        names=['sentence', 'sentiment'], 
        dtype={'sentence':str, 'sentiment':int}
)

# predict sentiments in the amazon data
predictions = model.predict(amazon['sentence'])

# print accuracy, 1 is perfect
accuracy = (predictions == amazon['sentiment']).sum()/predictions.size
print("Accuracy of %.3f on amazon data" % accuracy)



