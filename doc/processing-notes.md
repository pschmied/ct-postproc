# ETL
ogr2ogr is my homeboy

# Truck volumes on every roadway
Use WSDOT FGTSWA data (FGTSclass attribute) to predict the truck
counts observed in our trucks_counts layer. If this doesn't totally
suck, then we make up numbers for remainder of network.

Best bet: join i,j in truck counts table to i,j and j,i in edges
table, run regression.

recode NULL tonnage as 4
counts ~ tonnage
counts ~ tonnage + facilityInMIC?
counts ~ streetclass + facilityInMIC?

Problems: 
 1. multicollinearity with street classification (how to brain
    this?) - check that street classification isn't a better predictor
    or somethng.



http://www.wsdot.wa.gov/mapsdata/geodatacatalog/Maps/noscale/DOT_Cartog/FGTSWA.htm

# Identify left vs. right vs. non-turns
Peng's lit review. Probably threshold of degrees. Peter can probably
gin something up.

# Filter GPS

# Travel time
From the traces data, as is, minus stopping times > 3 min

# Travel distance
Geometric, from traces

# Travel speed
Median GPS speed

# Trip frequency
From data, self reported, as is

# Age
From data, self reported, as is

# Gender
From data, self reported, as is

# Number of collisions (trip level 200m)
All ten years? 

# Number of intersections (trip level 10m)

# Number of right turns (trip level 10m)

# Proportion of up-slope per trip

# Mean upslope

# Proportion of trips on cycling facilities

# Density... (trip level 200m)

# Land use mix (trip level 200m)

# Number of grocery stores (trip level 200m)

# Number of bus stops (trip level 200m)

# Origin access to closest facility (100m)

# Destination access to closest facility (100m)

# Energy consumption

# Speed limit (trip level)
