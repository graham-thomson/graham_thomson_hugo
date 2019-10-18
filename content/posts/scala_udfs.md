---
title: "Using Scala UDFs in PySpark"
date: 2019-10-14T14:18:21-04:00
draft: false
---

It is often required to write UDFs in Python to extend Sparks native functionality, especially when it comes to Spark's [Vector objects](https://spark.apache.org/docs/latest/api/python/pyspark.ml.html#pyspark.ml.linalg.Vectors) (the required data structure for feeding data to Spark's Machine Learning library). 

However, because of the serialization that must take place passing Python objects to the JVM and back, Python UDFs in Spark are inherently slow. To minimize the compute time when using UDFs it often much faster to write the UDF in Scala and call it from Python.

Let's consider a dataframe that contains the following feature vectors and we want to apply a log transformation to.

|count_features|
|---|
|[148.03, 12.09, 38.2, 23.16, 58.79, 57.69, 38.1, 244.06]|
|[71.86, 103.66, 158.05, 181.19, 32.17, 82.38, 10.06, 61.67]|

**The Python UDF Way**

First, let's take a look at how we might solve this using just Python + PySpark.

```python
import numpy as np
from pyspark.ml.linalg import Vectors
import pyspark.sql.functions as F

def np_to_sparse(np_array):
	"""
	Helper function to convert a numpy.ndarray to a pyspark.ml.linalg.SparseVector.
	:param np_array: Numpy Array.
	:return: PySpark Sparse Vector.
	"""
	non_zero_indices = np.nonzero(np_array)
	return Vectors.sparse(np_array.size, non_zero_indices[0], np_array[non_zero_indices])
    
@F.udf(returnType=VectorUDT())
def log_features_python_sparse(feature_vector):
	"""
	PySpark UDF to apply a Log + 1 (to avoid -inf for 0.0 values) transformation to a PySpark vector.
	:param feature_vector: PySpark Vector (dense/sparse).
	:return: Log + 1 transformed PySpark Sparse Vector.
	"""
	log_array = np.log(feature_vector.toArray() + 1, dtype=float)
	return np_to_sparse(log_array)
	
df = df.select(log_features_python_sparse("features").alias("log_features"))
df.show(2)
```

|log_features|
|---|
|[5.0, 2.57, 3.67, 3.18, 4.09, 4.07, 3.67, 5.5]|
|[4.29, 4.65, 5.07, 5.21, 3.5, 4.42, 2.4, 4.14]|

**The Scala UDF Way**

Now, let's write the Scala code to do the same transformation. We'll need a function that takes a Spark Vector, applies the same log + 1 transformation to each element and returns it as an (sparse) Vector.

We'll also define a function to register our new Scala UDF for use in Spark SQL.

```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.ml.linalg.{Vector, Vectors}
import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.expressions.UserDefinedFunction
import math.log

object FeatureUDFs {

	def logFeatures(a: Vector): Vector = {
	    Vectors.dense(a.toArray.map(x => log(x + 1.0))).toSparse
	  }
	  
  	def logFeaturesUDF: UserDefinedFunction = udf(logFeatures _ )
	  
  	def registerUdf: UserDefinedFunction = {
  		val spark = SparkSession.builder().getOrCreate()
  		spark.udf.register("logFeatures", (a: Vector) => logFeatures(a))
  }
	  
}
```

With our code written, we need to compile a `.jar` via our prefered build tool (I've been using [Gradle](https://gradle.org/)). Once built, copy the `.jar` to your `$SPARK_HOME/jars/` (e.g. `cp build/libs/spark-utils.jar $SPARK_HOME/jars/`). Now, let's access our Scala UDF from PySpark.

**Access via SparkSQL in PySpark**

The easiest way to access the Scala UDF from PySpark is via SparkSQL. 

```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()

# calling our registerUdf function from PySpark 
spark.sparkContext._jvm.FeatureUDFs.registerUdf()

# then access via SparkSQL
df = spark.sql("""
SELECT
    logFeatures(features) AS log_features
FROM
    df
""")
df.show(2)
```

|log_features|
|---|
|[5.0, 2.57, 3.67, 3.18, 4.09, 4.07, 3.67, 5.5]|
|[4.29, 4.65, 5.07, 5.21, 3.5, 4.42, 2.4, 4.14]|

**Access via PySpark API**

Accessing via the Python is a little bit more work as we need to convert Python Spark objects to Scala ones and vice a versa.

```python
from pyspark.sql import SparkSession
from pyspark.sql.column import Column, _to_java_column, _to_seq 

spark = SparkSession.builder.getOrCreate()

def log_features_scala_udf(feature_vector): 
    logFeaturesUDF = spark._jvm.FeatureUDF.logFeaturesUDF() 
    return Column(logFeaturesUDF.apply(_to_seq(spark.sparkContext, [feature_vector], _to_java_column)))

df = df.select(log_features_scala_udf("features").alias("log_features"))
df.show(2)
```

|log_features|
|---|
|[5.0, 2.57, 3.67, 3.18, 4.09, 4.07, 3.67, 5.5]|
|[4.29, 4.65, 5.07, 5.21, 3.5, 4.42, 2.4, 4.14]|