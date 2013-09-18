-- Drop traces_filter table if it already exists
DROP VIEW traces_filter_mbr;
DROP VIEW traces_bad;

-- Identify those traces:
-- 1.) whose minimum bounding box area is < 1,024m
-- 2.) 
CREATE VIEW traces_filter_mbr AS
SELECT trip_id, Area(Extent(Geometry)) < 1024 AS mbr_lt_1024
FROM traces
GROUP BY trip_id;


-- Create a view containing all the misfit links
CREATE VIEW traces_bad AS
SELECT a.rowid AS rowid, a.Geometry AS Geometry,
    a.trip_id AS trip_id
FROM traces AS a
JOIN traces_filter_mbr AS b USING (trip_id)
WHERE b.mbr_lt_1024 = 1;

-- Register the view containing misfit links
INSERT INTO views_geometry_columns
    (view_name, view_geometry, view_rowid, f_table_name,
    f_geometry_column, read_only)
  VALUES ('traces_bad', 'geometry', 'rowid', 'traces', 'geometry', 1);
