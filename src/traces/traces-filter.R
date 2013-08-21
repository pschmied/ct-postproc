library(RSQLite.spatialite)
library(ggplot2)
library(ggmap)
library(data.table)
library(manipulate)
library(iterators)

sqldrv <- dbDriver("SQLite")
con <- dbConnect(sqldrv, dbname = "~/Desktop/ct-postproc/data/working.sqlite")
init_spatialite(con)

# Get  GPS points
traces <- dbGetQuery(con, "SELECT OGC_FID, trip_id, latitude, longitude FROM traces")
traces$trip_id <- as.numeric(traces$trip_id)
traces$latitude <- as.numeric(traces$latitude)
traces$longitude <- as.numeric(traces$longitude)

# Unique trip IDs
trips <- as.numeric(unique(traces$trip_id))

# Function for plotting an individual trace for inspection
tmap <- function(trips, traces, tripno) {
  trip_id <- trips[tripno]
  trace <- traces[traces$trip_id == trip_id,]
  n <- max(trace$latitude)
  s <- min(trace$latitude)
  e <- max(trace$longitude)
  w <- min(trace$longitude)
  loc <- c(median(trace$longitude), median(trace$latitude))
  bounds <- c(w - .005, s - .005, e + .005, n + .005) 
  ggmap(get_map(location=bounds, maptype='roadmap', source="google", scale="auto")) +
    geom_path(data=trace, mapping=aes(x=longitude, y=latitude), size=1, color="red") +
    labs(title=paste("trip id = ", trip_id))
}


# Use the arrow keys to advance forward and backward through the traces
# manipulate(tmap(trips, traces, step), step=slider(1, length(trips)))


# Points cleaning methodology: Kalman filter? http://www.jstatsoft.org/v39/i02/paper

# The blatantly small on/off traces