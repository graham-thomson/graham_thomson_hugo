---
title: "Cosine Similarity Spark"
date: 2019-06-18T08:57:30-04:00
draft: false
tags: ["blog", "apache", "spark", "data science", "python"]
---

## Cosine similarity between a static vector and each vector in a Spark data frame

Ever want to calculate the cosine similarity between a static vector in Spark and each vector in a Spark data frame? Probably not, as this is an absurdly niche problem to solve but, if you ever have, here's how to do it using `spark.sql` and a UDF.

```python
# imports we'll need
import numpy as np
from pyspark.ml.linalg import *
from pyspark.sql.types import * 
from pyspark.sql.functions import *

# function to generate a random Spark dense vector, spark doesnt like np floats ;)
def random_dense_vector(length=10):
    return Vectors.dense([float(np.random.random()) for i in xrange(length)])

# create a random static dense vector
static_vector = random_dense_vector()

# create a random DF with dense vectors in column
df = spark.createDataFrame([[random_dense_vector()] for x in xrange(10)], ["myCol"])
df.limit(3).toPandas()

# write our UDF for cosine similarity
def cos_sim(a,b):
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

# apply the UDF to the column
df = df.withColumn("coSim", udf(cos_sim, FloatType())(col("myCol"), array([lit(v) for v in static_array])))
df.limit(10).toPandas()
```
So, what did we do:

* Imported necessary libraries.
* Instantiated a random static vector and a DataFrame that holds a bunch of random vectors.
* Wrote a UDF to calculate cosine similarity.
* Mapped the UDF over the DF to create a new column containing the cosine similarity between the static vector and the vector in that row.

This is trivial to do using RDDs and a .map() but in spark.sql you need to:

* Register the cosine similarity function as a UDF and specify the return type.
    * `udf(cos_sim, FloatType())`
* Pass the UDF the two arguments it needs: a column to map over AND the static vector we defined. However, we need to tell Spark that the static vector is an array of literal floats first using:
    * `(col("myCol"), array([lit(v) for v in static_array]))`


`sys.exit("All done!")`