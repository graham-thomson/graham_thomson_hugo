#!/bin/bash

# update covid19 notebook, will hang at 90% while fitting kmeans models
cd content/notebooks/ && \
source /Users/grahamthomson/PycharmProjects/neuclio/venv/bin/activate && \
papermill covid_notebook_mapping.ipynb covid_notebook_mapping_out.ipynb

# build site and upload to s3
cd /Users/grahamthomson/PycharmProjects/graham_thomson_hugo && \
hugo && \
aws s3 cp --recursive ./public/ s3://grahamflemingthomson.com/