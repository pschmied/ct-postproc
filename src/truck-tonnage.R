# install.packages(c("RSQLite", "car"), type="source")
library(RSQLite)
library(car)
sqldrv <- dbDriver("SQLite")
con <- dbConnect(sqldrv, dbname = "~/Desktop/ct-postproc/data/working.sqlite", loadable.extensions=T)
# spatialitestatus <- dbGetQuery(con, "SELECT load_extension('libspatialite.5')")
trucks <- dbGetQuery(con, "select trucks, tonnage, functionalclass, transrefedges.inode, transrefedges.jnode
                               from truck_counts
                               join transrefedges on
                               (truck_counts.inode=transrefedges.inode and 
                               truck_counts.jnode = transrefedges.jnode)
                               or
                               (truck_counts.jnode=transrefedges.inode
                               and
                               truck_counts.inode = transrefedges.jnode)") 

# Intersect our MIC layer with transrefedges. Note that this cannot be done in my
# environment due to a crash when I try to load the spatial extensions.
# So this was created externally in spatialite_gui

# CREATE TABLE edges_intersect_mic AS
# SELECT inode, jnode, 1 inmic
# FROM transrefedges, manufacturing_centers
# WHERE intersects(manufacturing_centers.GEOMETRY, transrefedges.GEOMETRY)
# AND transrefedges.ROWID IN
# (SELECT ROWID FROM SpatialIndex WHERE f_table_name="transrefedges" AND search_frame=manufacturing_centers.GEOMETRY);

mic_intersect <- dbGetQuery(con, "SELECT * from edges_intersect_mic")

# Easier to do this in R
trucks <- merge(x=trucks, y=mic_intersect, by=c("inode", "jnode"), all.x=TRUE)
trucks$inmic[is.na(trucks$inmic)] <- 0

# Can't remember what the tonnage classifications mean but Alon will document them here :-)
trucks$tonnage[is.na(trucks$tonnage)] <- 4
trucks$tonnage_4vs123 <- recode(trucks$tonnage, recodes="1:3 = 'onetwothree'; 4='four'")
trucks$tonnage_12vs34 <- recode(trucks$tonnage, recodes="1:2 = 'onetwo'; 3:4='threefour'")

nomic_4levels <- lm(trucks~as.factor(tonnage), data=trucks)
nomic_4vs123 <- lm(trucks~tonnage_4vs123, data=trucks)
nomic_12vs34 <- lm(trucks~tonnage_12vs34, data=trucks)

mic_4levels <- lm(trucks~as.factor(tonnage)+as.factor(inmic), data=trucks)
mic_4vs123 <- lm(trucks~tonnage_4vs123+as.factor(inmic), data=trucks)
mic_12vs34 <- lm(trucks~tonnage_12vs34+as.factor(inmic), data=trucks)