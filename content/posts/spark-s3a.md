---
title: "Spark + s3a:// = ❤️"
date: 2019-06-18T09:31:24-04:00
draft: false
tags: ["blog", "apache", "spark", "data science", "python"]
---

Typically our data science AWS workflows follow this sequence:

1. Turn on EC2.
2. Copy data from S3 via `awscli` to local machine file system.
3. Code references local data via `/path/to/data/`.
4. ???
5. Profit.

However, if the data you need to reference is relatively small or you're only passing over the data once, you can use [s3a://](https://wiki.apache.org/hadoop/AmazonS3) and stream the data direct from S3 into your code.

Say we have this script as `visits_by_day.py`

```python
# generally a good idea to alias spark functions to preserve python built in's namespace (e.g. sum)
import pyspark.sql.functions as F
from pyspark.sql import SparkSession

if __name__ == '__main__':
    spark = SparkSession.builder.getOrCreate()
    df = spark.read.parquet("s3a://some-s3-bucket/clients/client-x/data/omniture/dt=2017-04-*")
    df.groupBy("visit_day").agg(F.count("*").alias("no_obs")).orderBy("visit_day").show()
```

Or in Scala `VisitsByDay.scala`:

```javascript
import org.apache.spark.sql.SparkSession

/**
  * Created by grathoms on 6/14/17.
  */
object VisitsByDay {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder().getOrCreate()
    val df = spark.read.parquet("s3a://some-s3-bucket/clients/client-x/data/omniture/dt=2017-04-1*")
    df.groupBy("visit_day").count().orderBy("visit_day").show()
  }
}
```

Output:

```
+---------+------+
|visit_day| count|
+---------+------+
| 20170410|208823|
| 20170411|335355|
| 20170412|238535|
| 20170413|102363|
| 20170414|618847|
| 20170415|561687|
| 20170416|146944|
| 20170417|698453|
| 20170418|142700|
| 20170419|343261|
+---------+------+
```

If you've installed Spark from scratch you'll need additional JARs to use s3a that are not inlcuded with Spark at the time of authoring this post. 

```bash
# the jars you'll need to do this...
wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar -O $SPARK_HOME/jars/hadoop-aws-2.7.3.jar
wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar -O $SPARK_HOME/jars/aws-java-sdk-1.7.4.jar
```