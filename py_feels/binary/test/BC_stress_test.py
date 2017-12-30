# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 15:45:21 2017

stress test for binary sentiment classifier. currently
uses randomly generated sentences to simulate database
contents, runs predictions for 1M sentences, and outputs
hardware usage statistics

@author: rcehemann
"""

# we only need pandas, mongo and joblib to use the model
import pandas as pd
import platform
import psutil
from sqlalchemy import create_engine
from random import sample, randint
from sklearn.externals.joblib import load

# connect to psql db

engine = create_engine('postgresql+psycopg2://wojak:@localhost/bit_feels_dev')

tweets = pd.read_sql_table('tweets', engine, index_col='id', columns=['text'])
users  = pd.read_sql_table('users',  engine)
# words for random generation

# load fitted model
model = load('../model/binary_classifier.pckl')

iproc_usage = psutil.cpu_percent()
imem_usage  = psutil.virtual_memory().used
proc_usage  = 0.
mem_usage   = 0.

# run through the DB of tweets 1M times
batch_size = tweets.shape[0]
total_size = int(100000)*batch_size
for batch in range(total_size // batch_size):
    sents = []
    while len(sents) < batch_size:
        sents.append(' '.join(sample(words, randint(5, 20))))
    
    predictions = model.predict(sents)
    
    proc_usage = max(proc_usage, psutil.cpu_percent())
    mem_usage  = max(mem_usage,  psutil.virtual_memory().used)
        
print(platform.processor())
print("Cores: %2d @ %.0f MHz" % (psutil.cpu_count(), psutil.cpu_freq().max))
print("RAM  : %3.2f GB" % (psutil.virtual_memory().total/1073741824))
print(50*'-')
print("PyFeels max CPU utilization: %.3f %%" % (proc_usage - iproc_usage))
print("PyFeels max RAM utilization: %.3f GB" % ((mem_usage - imem_usage)/1073741824))
    