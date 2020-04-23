#!/bin/bash

hugo && aws s3 cp --recursive ./public/ s3://grahamflemingthomson.com/