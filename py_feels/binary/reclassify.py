# -*- coding: utf-8 -*-
"""
Created on Sat Jan 13 15:51:35 2018

reclassifies all tweets in the bit_feels database,
for use only when classifiers have been added or changed.

takes one argument: env = "dev" or "prod"

@author: blenderherad
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
query  = "SELECT id, text FROM tweets"
tweets = pd.read_sql(query, engine)    

# if this is the first model to 
def rep_or_app(name):    
    if list(fitted_models.keys()).index(name) == 0:
        return 'replace'
    else:
        return 'append'

for name in fitted_models:
    # load fitted model
    model = load(fitted_models[name])
    
    # predict sentiments in dataframe
    sentiments = model.predict(tweets.text.values)
    
    # construct feels DataFrame for passing back to SQL
    feels = pd.DataFrame()
    feels['sentiment']   = list(map(str, sentiments))
    feels['classifier']  = name
    feels['tweet_id']    = tweets.id.values
    
    # store prediction time
    time_now = str(datetime.datetime.now())
    feels['inserted_at'] = time_now
    feels['updated_at']  = time_now
    
    # write predictions to 'feels' table in database
    feels.to_sql('feels', engine, if_exists=rep_or_app(name), index=False)
    