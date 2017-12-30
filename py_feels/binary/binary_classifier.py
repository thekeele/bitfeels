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

# load fitted model
model = load('./model/binary_classifier.pckl')

# connect to  SQL database, query for last item in 'tweets' table
engine = create_engine('postgresql+psycopg2://wojak:@localhost/' + env)
query  = "SELECT tweet_id, text FROM tweets ORDER BY inserted_at DESC LIMIT 1"
tweets = pd.read_sql(query, engine)

# predict sentiments in dataframe
sentiments = model.predict(tweets.text.values)

# construct feels DataFrame for passing back to SQL
feels = pd.DataFrame()
feels['sentiment']   = sentiments
feels['classifier']  = dict(model.steps)['clf'].__class__.__name__
feels['tweet_id']    = tweets.tweet_id.values

# store prediction time
time_now = str(datetime.datetime.now())
feels['inserted_at'] = time_now
feels['updated_at']  = time_now

# write predictions to 'feels' table in database
feels.to_sql('feels', engine, if_exists='append', index=False)
