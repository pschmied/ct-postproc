# Overview

This document describes the methods used to process the raw
CycleTracks GPS data, and the methods used to generate various other
variables.


# List of variables

Per Alon's email dated 11 September, we will consider the following
varables:

| Variable                              | Unit  |
|---------------------------------------+-------|
| Travel Time                           | min   |
| Travel Distance                       | km    |
| Travel Speed                          | m/s   |
| Trip Frequency                        | cat   |
| Age                                   | yr    |
| Gender                                | cat   |
| # Intersections                       | n     |
| # Left Turns                          | n     |
| # Right Turns                         | n     |
| Share of trip up-slope                | ratio |
| Mean Up-Slope                         | ???   |
| Max Up-Slope                          | ???   |
| Share of trip on bike facility        | ratio |
| Land-use mix (corridor)               | index |
| Origin dist. to closest facility      | km    |
| Dest. dist. to closest facility       | km    |
| Share of trip along commercial parcel | ratio |



# Loading data into spatial database

All data are loaded into a spatialite database via the `ogr2ogr`
utility. Because the `ogr2ogr` command is invoked multiple times, this
process is orchestrated by a single bash shell script, `etl.sh` which
allows for consistency in setting parameters to `ogr2ogr`.

We received data in a variety of formats, including ESRI File
Geodatabase, ESRI Shapefile, and CSV. For consistency, and
compatibility with common web-based mapping tools, all spatial data
were converted / reprojected into EPSG 3857 format
(http://spatialreference.org/ref/sr-org/7483/).


# Traces

Traces are collected as a series of GPS points, downloaded in comma
separated format from the CycleTracks server housed at SFCTA. By
virtue of being GPS traces, these require some significant cleaning.
This is exacerbated by the variable quality and precision of the GPS
receivers in the mobile phones used in this study.

## Removing unusable traces

There are several criteria by which a trace is removed from
consideration in our analysis:
1. Minimum bounding rectangle of less than 1024m^2. This threshold is
   somewhat arbitrary but covers the case where a user aborted logging
   early, but still uploaded the trip.
2. ??? or more GPS points exceed ??? m/s, indicating that the user
   spent some portion of his trip traveling by a motorized,
   non-bicycle mode. ??? points is an arbitrary threshold, however
   seems to be sufficiently high as to tolerate some incorrect data, but is
   sufficiently low as to bursts of speed deemed impossible for
   bicyclists to achieve.
3. Fewer than ??? GPS points exceeding ??? m/s. Trips in which the
   user did not, at any time, achieve a speed greater than ??? were
   deemed most likely to be a non-bicycling trip.
4. Trips in which the time between recording GPS points exceeded ???
   minutes. Many such trips exist, believed to be the result of iPhone
   users pausing the logging function on their phone in error. These
   traces are unusable because there are significant gaps in the
   record.

## Handling outlier GPS points / noise

## Converting GPS traces to network routes
