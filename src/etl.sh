#!/bin/bash
# Extract transform and load procedures

# Make for nominal portability to PostGIS
ofmt="-f SQLite"
basepath=~/Desktop/ct-postproc/data
orig=$basepath/original
opath=$basepath/cycletracks.sqlite
flags="-t_srs EPSG:4326 -dsco SPATIALITE=YES -gt 65536"
append=$flags" -append -update"

rm $opath

# Full PSRC roads network (TransRefEdges and TransRefJunctions)
ogr2ogr $ofmt $opath $orig/PSRC_Net.gdb $flags

# Collisions
ogr2ogr $ofmt $opath $orig/CollisionsData/Merged/Collisions_Merged.shp \
$append -nln collisions

# Bicycle facilities - FAILS (need to bring up to speed in ArcCatalog)
ogr2ogr $ofmt $opath $orig/bikefacility/bikefacilities.gdb $append

# CycleTracks Traces
ogr2ogr $ofmt $opath $orig/cycletracks/traces.csv $append -s_srs EPSG:4326
spatialite $opath \
"SELECT AddGeometryColumn('traces','Geometry',4326,'POINT',2)"
spatialite $opath \
"UPDATE traces SET Geometry=MakePoint(longitude,latitude, 4326);"

# CycleTracks Trips (fake SRS again)
ogr2ogr $ofmt $opath \
$orig/cycletracks/trips.csv $append -s_srs EPSG:4326

# Grocery stores
ogr2ogr $ofmt $opath \
$orig/grocery/Snohomish_major_stores_clean_1_w_PIN_and_SF_FINAL.shp \
$append -nln grocery_snohomish

ogr2ogr $ofmt $opath $orig/grocery/KITSAP_FINAL_COMPLETE_20090401.shp \
$append -nln grocery_kitsap

ogr2ogr $ofmt $opath $orig/grocery/grocery_stores_20090311.shp \
$append -nln grocery_king

# Mode attributes - table only, fake input srs
ogr2ogr $ofmt $opath $orig/NetAtts.gdb \
$append -s_srs EPSG:4326 -nln network_attributes

# Junction elevations
ogr2ogr $ofmt $opath $orig/network/junction_elevation.gdb \
$append -nln elevation_junctions

# TransRefEdges with elevation
ogr2ogr $ofmt $opath $orig/network/peters_transrefedges.gdb \
$append -nln elevation_edges

# Parcels; appending -skipfailures, but should validate we're not
# losing much valid data, though looks like only one geometry. Slow as
# fsck.
ogr2ogr $ofmt $opath $orig/parcel/prcl05/prcl05.shp \
$append -skipfailures -nln parcels_2005

# Truck volumes - waiting on Alon's guidance
ogr2ogr $ofmt $opath $orig/Truck_Volumes/combined_classification_counts.shp \
$append -nln truck_counts

# Truck freight functional classification crap
ogr2ogr $ofmt $opath $orig/FGTSWA.gdb \
$append -nln freight_classification

# Manufacturing and Industrial Centers
ogr2ogr $ofmt $opath $orig/mic/micen_fixed.sqlite \
$append -nln manufacturing_centers
