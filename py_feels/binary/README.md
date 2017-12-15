# PyFeels binary sentiment classifier
* requires pandas
* requires scikit/learn

A naive Bayesian classifier using multinomial distributions and word-count feature vectors classifies a tweet as positive, negative or neutral.

Training is done in ./training/binary_classifier_training.py and the model is pickled and stored in ./model to be called by the predictor script binary_classifier.py
