-- A handler function that returns the northing of a provided grid ref in the determined datum (see find_datum for more details)

CREATE OR REPLACE FUNCTION osgr_process_northing(gridref TEXT)
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    datum INT;
    
BEGIN
    datum = CS_FIND_DATUM(gridref);

    CASE datum
        WHEN 29901 THEN
            RETURN OSGR_ING_NORTHING(gridref);
        WHEN 27700 THEN
            RETURN OSGR_GB_NORTHING(gridref);
        WHEN 32630 THEN
            RETURN OSGR_CI_NORTHING(gridref);
        ELSE
            RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END CASE;

END;
$$;