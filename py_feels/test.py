# -*- coding: utf-8 -*-
"""
Created on Mon Dec  4 22:35:07 2017

@author: blenderherad
"""

from sklearn.ensemble import RandomForestRegressor
import numpy as np
train = np.linspace(0,1,10).reshape(-1,1)
y     = np.array(list(map(lambda x: x**2, train))).ravel()
test  = np.linspace(11,1,20).reshape(-1,1)

clf = RandomForestRegressor()

clf.fit(train, y)
preds = clf.predict(test)
print(preds)
print("Success!")
