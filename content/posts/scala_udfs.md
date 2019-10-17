---
title: "Using Scala UDFs in PySpark"
date: 2019-10-14T14:18:21-04:00
draft: false
---

It is often required to write UDFs in Python to extend Sparks native functionality, especially when it comes to Spark's [Vector objects](https://spark.apache.org/docs/latest/api/python/pyspark.ml.html#pyspark.ml.linalg.Vectors) (the required data structure for feeding data to Spark's Machine Learning library). 

However, because of the serialization that must take place passing Python objects to the JVM and back, Python UDFs in Spark are inherently slow. To minimize the compute time when using UDFs it often much faster to write the UDF in Scala and call it from Python.


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
```