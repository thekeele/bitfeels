wget https://repo.continuum.io/miniconda/Miniconda3-4.3.30-Linux-x86_64.sh
bash Miniconda3-4.3.30-Linux-x86_64.sh
/home/thekeele/miniconda3/bin/conda install -y numpy
/home/thekeele/miniconda3/bin/conda install -y scipy
/home/thekeele/miniconda3/bin/conda install -y pandas
/home/thekeele/miniconda3/bin/conda install -y scikit-learn
#/home/thekeele/miniconda3/bin/conda install nltk-with-data
rm -f Miniconda3-4.3.30-Linux-x86_64.sh
/home/thekeele/miniconda3/bin/python test.py
