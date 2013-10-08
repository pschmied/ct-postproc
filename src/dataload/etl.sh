#!/bin/bash
# Extract transform and load procedures

# Make for nominal portability to PostGIS
ofmt="-f SQLite"
basepath=~/Desktop/ct-postproc/data
orig=$basepath/original
opath=$basepath/cycletracks.sqlite
flags="-t_srs EPSG:3857 -a_srs EPSG:3857 -dsco SPATIALITE=YES -gt 65536 -nlt PROMOTE_TO_MULTI"
append=$flags" -append -update"

rm $opath

# Full PSRC roads network (TransRefEdges and TransRefJunctions)
echo "psrc network"
ogr2ogr $ofmt $opath $orig/PSRC_Net.gdb $flags

# Bicycle facilities - FAILS (need to bring up to speed in ArcCatalog)
echo "bike facilities"
ogr2ogr $ofmt $opath $orig/bikefacility/bikefacilities.gdb \
transrefedges_bikefacil -nln bike_transrefedges $append

ogr2ogr $ofmt $opath $orig/bikefacility/bikefacilities.gdb \
transrefjunctions -nln bike_transrefjunctions $append

# CycleTracks Traces. This is a little tricker. We create a virtual
# OGR layer in order to project WGS84 lat/lon on the fly.
vrtrace=$basepath/traces.vrt
echo "traces"
echo "<OGRVRTDataSource>
    <OGRVRTLayer name='traces'>
        <SrcDataSource>$orig/cycletracks/traces.csv</SrcDataSource>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>WGS84</LayerSRS>
        <GeometryField encoding='PointFromColumns' x='Longitude' y='Latitude'/>
    </OGRVRTLayer>
</OGRVRTDataSource>" > $vrtrace

ogr2ogr $ofmt $opath $vrtrace $append
rm $vrtrace

# CycleTracks Trips (fake SRS again)
echo "trips"
ogr2ogr $ofmt $opath \
$orig/cycletracks/trips.csv $append -s_srs EPSG:3857


# Mode attributes - table only, fake input srs
echo "mode attributes"
ogr2ogr $ofmt $opath $orig/NetAtts.gdb \
$append -s_srs EPSG:3857 -nln network_attributes

# Junction elevations
echo "junction elevations"
ogr2ogr $ofmt $opath $orig/network/junction_elevation.gdb \
$append -nln elevation_junctions

# TransRefEdges with elevation
echo "edges elevations"
ogr2ogr $ofmt $opath $orig/network/peters_transrefedges.gdb \
$append -nln elevation_edges

# Parcels; appending -skipfailures, but should validate we're not
# losing much valid data, though looks like only one geometry. Slow as
# fsck.
echo "parcels"
ogr2ogr $ofmt $opath $orig/parcel/prcl05/prcl05.shp \
$append -skipfailures -nln parcels_2005
