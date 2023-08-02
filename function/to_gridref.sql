-- Converts a provided easting, northing, accuracy, and datum into an OS grid reference for the provided datum

CREATE OR REPLACE FUNCTION osgr_to_gridref(
        easting INT,
        northing INT,
        accuracy INT,
        datum INT
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$
BEGIN
    CASE(datum)
        WHEN 29901 THEN
            RETURN OSGR_TO_ING(easting, northing, accuracy);
        WHEN 27700 THEN
            RETURN OSGR_TO_GB(easting, northing, accuracy);
        WHEN 32630 THEN
            RETURN OSGR_TO_CI(easting, northing, accuracy);
        ELSE
            RAISE EXCEPTION 'Invalid datum supplied: %', datum;
        END CASE;
END;
$$;