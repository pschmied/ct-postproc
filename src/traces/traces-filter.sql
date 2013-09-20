-- Drop traces_filter table if it already exists
DROP VIEW traces_filter_mbr;
DROP VIEW traces_filter_hi_speed;
DROP VIEW traces_filter_lo_speed;
DROP VIEW traces_filter_gaps;

DROP TABLE traces_bad;

-- -- Remove the spatial views that have already been registered
-- DELETE FROM views_geometry_columns
-- WHERE view_name = 'traces_bad';

-- Identify those traces:
-- 1.) whose minimum bounding box area is < 1,024m
-- 2.) that contain > 10 points exceeding 15.65 m/s (NOTE: review
-- thresholds!)
-- 3.) that contain < 20 points exceeding minimum 4.5 m/s threshold
-- 4.) that have gaps in the recording of points that exceed 1 minute.
CREATE VIEW traces_filter_mbr AS
SELECT trip_id, Area(Extent(Geometry)) < 1024 AS mbr_lt_1024
FROM traces
GROUP BY trip_id;

CREATE VIEW traces_filter_hi_speed AS
SELECT trip_id, count(trip_id) > 10 AS excess_speed
FROM traces
WHERE speed > 15.65
GROUP BY trip_id;

CREATE VIEW traces_filter_lo_speed AS
SELECT trip_id, count(trip_id) < 20 AS insufficient_speed
FROM traces
WHERE speed > 4.5
GROUP BY trip_id;

CREATE VIEW traces_filter_gaps AS
SELECT DISTINCT trip_id,
(SELECT strftime('%s', b.recorded)
     FROM traces b
     WHERE b.OGC_FID = a.OGC_FID + 1
     AND a.trip_id = b.trip_id) - strftime('%s', a.recorded) > 60 gaps
FROM traces a
WHERE gaps = 1;



-- Create a view containing all the misfit links
CREATE TABLE traces_bad AS
SELECT a.rowid AS rowid, a.Geometry AS Geometry,
    a.trip_id AS trip_id,
    b.mbr_lt_1024 AS mbr_lt_1024,
    c.excess_speed AS excess_speed,
    d.insufficient_speed AS insufficient_speed,
    e.gaps AS gaps
FROM traces AS a
LEFT JOIN traces_filter_mbr AS b USING (trip_id)
LEFT JOIN traces_filter_hi_speed AS c USING (trip_id)
LEFT JOIN traces_filter_lo_speed AS d USING (trip_id)
LEFT JOIN traces_filter_gaps AS e USING (trip_id)
WHERE b.mbr_lt_1024 = 1
OR c.excess_speed = 1
OR d.insufficient_speed = 1
OR e.gaps = 1;

SELECT RecoverGeometryColumn('traces_bad', 'Geometry', 3857,
'POINT',2);

-- -- Register the view containing misfit links
-- INSERT INTO views_geometry_columns
--     (view_name, view_geometry, view_rowid, f_table_name,
--     f_geometry_column, read_only)
--   VALUES ('traces_bad', 'geometry', 'rowid', 'traces', 'geometry', 1);
