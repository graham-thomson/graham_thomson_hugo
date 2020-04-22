---
title: "Plotting COVID-19 Cases in the US"
date: 2020-04-21T12:26:20-04:00
draft: false
---

* Data supplied by [NYTimes Github](https://github.com/nytimes/covid-19-data).
* Beautiful (and easy) plots with [Plotly Express](https://plotly.com/python/plotly-express/#plotly-express).
* Maps Powered by [MapBox (OpenStreetMaps)](https://www.mapbox.com/)
* Full Python Code on [Github](https://gist.github.com/graham-thomson/08791e9faf705d6bbdf0188b9c0a9c3b)

## Map View

* Note this was limited to the 50 states, DC, and PR.

{{< rawhtml >}}
<iframe src="../plots/counties_map.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}

## Time Series View

* Note both of these plots have a log scale on the y-axis.

{{< rawhtml >}}
<iframe src="../plots/cases_by_state.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}

{{< rawhtml >}}
<iframe src="../plots/deaths_by_state.html" height="500" width=90% style="border:none;"></iframe>
{{< /rawhtml >}}
