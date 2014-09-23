CREATE TYPE shape_row AS (shape_id text, shape_pt_sequence int, shape_pt_lat double precision, shape_pt_lon double precision, shape_dist_traveled int);

CREATE OR REPLACE FUNCTION generate_gtfs_shape(shape_id text, geojson text)
RETURNS SETOF shape_row
AS $$
DECLARE
  row shape_row;
  g geometry;
BEGIN
  g := ST_SetSRID(ST_GeomFromGeoJSON(geojson), 4326);
  FOR i in 1 .. ST_NumPoints(g) LOOP
    SELECT INTO row shape_id, i, ST_Y(ST_PointN(g, i)), ST_X(ST_PointN(g, i)), CASE WHEN i = 1 THEN 0 ELSE round(ST_Distance(Geography(ST_PointN(g, i - 1)), Geography(ST_PointN(g, i)))) END;
    RETURN NEXT row;
  END LOOP;
END
$$ LANGUAGE plpgsql;
