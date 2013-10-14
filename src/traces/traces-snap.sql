-- Clear out old versions if they exist
SELECT DisableSpatialIndex('transrefjunctions_50m', 'Geometry');

DROP TABLE transrefjunctions_50m;
DROP TABLE junctions_intersect_tracepoints;

-- Create a buffered version of transrefjunctions and enable RTree
-- spatial index.
CREATE TABLE transrefjunctions_50m AS
SELECT psrcjunctid, ST_Buffer(Geometry, 50) Geometry
FROM transrefjunctions;

SELECT RecoverGeometryColumn('transrefjunctions_50m', 'Geometry',
3857, 'POLYGON', 2);

SELECT CreateSpatialIndex('transrefjunctions_50m', 'Geometry');

-- Test for intersection of buffered transrefjunctions and gps points
CREATE TABLE gps_intersect_transrefjunctions_50m AS
SELECT b.trip_id trip_id, a.psrcjunctid psrcjunctid,
       b.OGC_FID OGC_FID
FROM transrefjunctions_50m a, traces b
WHERE ST_Intersects(a.Geometry, b.Geometry)
AND b.ROWID IN
    (SELECT ROWID FROM SpatialIndex
    WHERE f_table_name = "traces" and search_frame = a.GEOMETRY);

-- Get the number of GPS points by trip and intersected junction
CREATE VIEW points_by_trip_junction AS
SELECT trip_id, psrcjunctid, count(OGC_FID) npoints
FROM gps_intersect_transrefjunctions_50m
GROUP BY trip_id, psrcjunctid;



-- CREATE TABLE ordered_junctions AS
-- SELECT b.trip_id trip_id, a.psrcjunctid psrcjunctid,
--        count(b.OGC_FID) npoints,
--        min(strftime('%s', b.recorded)) mintime,
--        max(strftime('%s', b.recorded)) maxtime
-- FROM transrefjunctions_50m a, traces b
-- WHERE ST_Intersects(a.Geometry, b.Geometry)
-- AND b.ROWID IN
--     (SELECT ROWID FROM SpatialIndex
--     WHERE f_table_name = "traces" AND search_frame = a.GEOMETRY)
-- GROUP BY b.trip_id, a.psrcjunctid
-- ORDER BY mintime;
