# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

Binary sentiment classifier for BitFeels. Loads model fit by
binary_classifier_training.py and produces predictions. Currently
just runs on amazon training data, but will eventually pull from
mongo DB of tweets and return sentiments

@author: rcehemann
"""

import pandas as pd
import pickle
import datetime
from sys import argv
from sqlalchemy import create_engine
from sklearn.externals.joblib import load

# check environment
if len(argv) < 2 or argv[1] == "dev":
    env = "bit_feels_dev"
elif argv[1] == "prod":
    env = "bit_feels"
else:
    raise EnvironmentError("Environment should be 'dev' or 'prod'")

# load model dictionary
with open('./model/model_dict.pckl', 'rb') as f:
    fitted_models = pickle.load(f)

""" We will loop through the fitted models, load the classifier and push
    the feels into the database """

# connect to  SQL database, query for last item in 'tweets' table
engine = create_engine('postgresql+psycopg2://wojak:@localhost/' + env)
query  = "SELECT tweet_id, text FROM tweets ORDER BY inserted_at DESC LIMIT 1"
tweets = pd.read_sql(query, engine)    

for name in fitted_models:
    # load fitted model
    model = load(fitted_models[name])
    
    # predict sentiments in dataframe
    sentiments = model.predict(tweets.text.values)
    
    # construct feels DataFrame for passing back to SQL
    feels = pd.DataFrame()
    feels['sentiment']   = list(map(str, sentiments))
    feels['classifier']  = name
    feels['tweet_id']    = tweets.tweet_id.values
    
    # store prediction time
    time_now = str(datetime.datetime.now())
    feels['inserted_at'] = time_now
    feels['updated_at']  = time_now
    
    # write predictions to 'feels' table in database
    feels.to_sql('feels', engine, if_exists='append', index=False)
