# Library installation was a little tricky
# install.packages(c("RSQLite", "rgdal", "car", "devtools"))
# library(devtools)
# install_github(repo="RSQLite.spatialite", username="pschmied")
library(RSQLite.spatialite)
library(car)

sqldrv <- dbDriver("SQLite")
con <- dbConnect(sqldrv, dbname = "~/Desktop/ct-postproc/data/working.sqlite")
init_spatialite(con)
trucks <- dbGetQuery(con, "select trucks, tonnage, functionalclass, transrefedges.inode, transrefedges.jnode
                               from truck_counts
                               join transrefedges on
                               (truck_counts.inode=transrefedges.inode and 
                               truck_counts.jnode = transrefedges.jnode)
                               or
                               (truck_counts.jnode=transrefedges.inode
                               and
                               truck_counts.inode = transrefedges.jnode)") 

mic_intersect <- dbGetQuery(con, "SELECT inode, jnode, 1 inmic
  FROM transrefedges, manufacturing_centers
  WHERE intersects(manufacturing_centers.GEOMETRY, transrefedges.GEOMETRY)
  AND transrefedges.ROWID IN
    (SELECT ROWID FROM SpatialIndex
    WHERE f_table_name='transrefedges'
    AND search_frame=manufacturing_centers.GEOMETRY);")

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