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

import pandas as pd
import pytz
from dateutil import parser
from numpy import linspace, digitize, mean, std
from datetime import datetime
from sys import argv
from sqlalchemy import create_engine

# check environment, parse arguments
if len(argv) < 2:
    window = 48.
    env = "bit_feels_dev"
elif len(argv) < 3 or argv[2] == "dev":
    window = argv[1]
    env = "bit_feels_dev"
elif argv[2] == "prod":
    window = argv[1]
    env = "bit_feels"
else:
    raise EnvironmentError("second argument should be 'dev' or 'prod'")

# set up SQL connection
engine = create_engine('postgresql+psycopg2://wojak:@localhost/' + env)

def ts_to_td(created_at):
    """
        parses the created_at time string
        and returns a timestamp
    """
    created_at = parser.parse(created_at)
    return created_at.timestamp()

def time_window(times, window):
    """
        function to partition a time series
        into time windows. takes a numerical value
        in HOURS for the requested time window.
        bins are statically sized and the number of bins
        is calcluated based on the earliest timestamp in the db
    """
    t_min  = min(times.values)
    t_max  = max(times.values)
    n_bins = int((t_max - t_min) / 3600 / window)
    bins   = linspace(t_min, t_max, num=n_bins)
    windows = digitize(times, bins, right=True)
    bins = [datetime.fromtimestamp(t) for t in bins]
    bins = [t.strftime("%a %b %d %H:%M:%S +0000 %Y") for t in bins]
    return windows, bins

def mean_and_std(times):
    return mean(times), std(times)

query  = "SELECT tweet_id, sentiment, classifier FROM feels"
feels  = pd.read_sql(query, engine)
query  = "SELECT created_at, tweet_id FROM tweets"
tweets = pd.read_sql(query, engine)

# merge on tweet id to get tweet times 
feeltimes = pd.merge(feels, tweets, on='tweet_id')
del feels, tweets

# prep the feels for binning
feeltimes = feeltimes[feeltimes['sentiment'] != "0"].reset_index(drop=True)
feeltimes.loc[:,'sentiment'] = feeltimes.sentiment.apply(lambda x: int(x))

stats = pd.DataFrame()
feeltimes['created_at'] = feeltimes.created_at.apply(
        ts_to_td
)

assignments, bins = time_window(feeltimes.loc[:,'created_at'], window)
feeltimes.loc[:,'assignment'] = assignments

times = pd.DataFrame({'time':bins, 'window':list(range(len(bins)))})

# group by classifier and time-window, then compute mean and std-dev for each
group_stats = feeltimes.groupby(['classifier', 'assignment'])['sentiment'].apply(
        mean_and_std
)

# build stats table by iterating through classifiers, copying times
# splitting mean and std into separate columns then filling NaN values
# with zeroes 
stats = pd.DataFrame(columns=['time', 'classifier', 'mean', 'std'])
for clf in feeltimes.classifier.unique():
    tmp = pd.DataFrame(times['time'])
    tmp[['mean', 'std']] = group_stats[clf].apply(pd.Series)
    tmp['classifier'] = clf
    tmp.fillna(0., inplace=True)
    stats = stats.append(tmp)

# write predictions to 'feels' table in database
stats.to_sql('stats', engine, if_exists='replace', index=False)
