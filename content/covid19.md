---
title: "Plotting COVID-19 Cases in the US"
date: 2020-04-22T20:07:54-04:00
draft: false
---

* Data supplied by [NYTimes Github](https://github.com/nytimes/covid-19-data).
* Beautiful (and easy) plots with [Plotly Express](https://plotly.com/python/plotly-express/#plotly-express).
* Maps Powered by [MapBox (OpenStreetMaps)](https://www.mapbox.com/)
* Full Python Code on [Github](https://github.com/graham-thomson/graham_thomson_hugo/blob/master/content/notebooks/covid_notebook_mapping.ipynb)

## Map View

* Note this was limited to the 50 states, DC, and PR.

{{< rawhtml >}}
<iframe src="../plots/counties_map.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}

## K-Means Clustering on COVID-19 Cases 

* Thought it might be interesting to run K-Means on all the cases in the US. 
To do so, I exploded the county dataset from its aggregated form to each row representing a single case of COVID-19. 
It could be interesting to normalize the data for population.
* Ran `k=range(2, 22, 2)`
* Some interesting findings: 
    * **k=2** - East vs West. Even though the 26 states east of the Mississippi River make up [~58% of the total US population](https://en.wikipedia.org/wiki/Eastern_United_States)
    we see ~85% of US cases represented by the cluster with its centroid near Carroll County, Maryland.
    * **k=4** - The northeast (~61%), the south (~14%), the midwest (~16%), and the west (~9%).
    * **k=12** - New Orleans emerges as a separate cluster from Texas. The [DMV](https://en.wikipedia.org/wiki/Washington_metropolitan_area#Nomenclature), Baltimore, and Philly gets its own cluster.
    * **k=16** - New England and Boston finally get their own cluster. 

{{< rawhtml >}}
<iframe src="../plots/covid_kmeans.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}

## Time Series View

* Note both of these plots have a log scale on the y-axis.

{{< rawhtml >}}
<iframe src="../plots/cases_by_state.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}

{{< rawhtml >}}
<iframe src="../plots/deaths_by_state.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}
