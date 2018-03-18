# -*- coding: utf-8 -*-
"""
Created on Sat Jan 20 14:50:21 2018

Pulls feels and tweet times from the bit_feels database and performs
a time-window average of the sentiments for plotting. pushes means,
standard devaitions, classifier names and bin times into the 'stats'
table of bit_feels. Takes two arguments: window and env

window is the width of the time-bin in hours,
env is "dev" or "prod"

@author: rcehemann
"""

# constant window width
WINDOW = 24

import pandas as pd
from dateutil import parser
from numpy import linspace, digitize, mean, std
from datetime import datetime
from sys import argv
from math import ceil
from sqlalchemy import create_engine

# check environment, parse arguments
if len(argv) < 2 or argv[1] == "dev":
    env = "bit_feels_dev"
elif argv[1] == "prod":
    env = "bit_feels"
else:
    raise EnvironmentError("Environment should be 'dev' or 'prod'")

def ts_to_td(created_at):
    """
        parses the created_at time string
        and returns a timestamp
    """
    created_at = parser.parse(created_at)
    return int(created_at.strftime("%s"))

def time_bins(times, window):
    """
        takes the time data from all tweets and computes
        bins based on the window width (in hours). returns bins
    """
    t_min  = min(times)
    t_max  = max(times)
    n_bins = ceil((t_max - t_min) / 3600 / float(window))
    fltbins = linspace(t_min, t_max, num=n_bins)

    return fltbins

def mean_and_std(times):
    return mean(times), std(times)

# set up SQL connection
engine = create_engine('postgresql+psycopg2://wojak:@localhost/' + env)

query  = "SELECT tweet_id, sentiment, classifier FROM feels"
feels  = pd.read_sql(query, engine)
query  = "SELECT created_at, id FROM tweets"
tweets = pd.read_sql(query, engine)
feels.rename(columns={'tweet_id':'id'}, inplace=True)

# merge on tweet id to get tweet times
feeltimes = pd.merge(feels, tweets, on='id')
del feels, tweets

# transform datetimes to timestamps
feeltimes['created_at'] = feeltimes.created_at.apply(
        ts_to_td
)

# compute time bins, store string labels in data frame
fltbins = time_bins(feeltimes.created_at.values, WINDOW)
times = pd.DataFrame({
    'time':fltbins,
    'window':list(range(len(fltbins)))
})

# prep the feels for binning
feeltimes = feeltimes[feeltimes['sentiment'] != "0"].reset_index(drop=True)
feeltimes.loc[:,'sentiment'] = feeltimes.sentiment.apply(lambda x: int(x))

# compute bin assignments and add them to feeltimes frame
assignments = digitize(feeltimes.loc[:,'created_at'], fltbins, right=True)
feeltimes.loc[:,'assignment'] = assignments

# group by classifier and time-window, then compute mean and std-dev for each
group_stats = feeltimes.groupby(['classifier', 'assignment'])['sentiment'].apply(
        mean_and_std
)

# build stats table by iterating through classifiers, copying times
# splitting mean and std into separate columns then filling NaN values
# with zeroes
stats = pd.DataFrame(columns=['time', 'classifier', 'mean', 'std'])
for clf in feeltimes.classifier.unique():
    tmp = pd.DataFrame(times['time'].apply(lambda x: 1000*int(x))) # conv to ms
    tmp[['mean', 'std']] = group_stats[clf].apply(pd.Series)
    tmp['classifier'] = clf
    tmp.fillna(0., inplace=True)
    stats = stats.append(tmp)

# write predictions to 'feels' table in database
stats.to_sql('stats', engine, if_exists='replace', index=False)