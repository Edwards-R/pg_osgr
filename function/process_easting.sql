-- A handler function that returns the easting of a provided grid ref in the determined datum (see find_datum for more details)

CREATE OR REPLACE FUNCTION osgr_process_easting(
        gridref TEXT
    )
    RETURNS INT
    LANGUAGE plpgsql
AS $$
DECLARE
    datum INT;
    
BEGIN
    datum = OSGR_FIND_DATUM(gridref);

    CASE datum
        WHEN 29901 THEN
            RETURN OSGR_ING_EASTING(gridref);
        WHEN 27700 THEN
            RETURN OSGR_GB_EASTING(gridref);
        WHEN 32630 THEN
            RETURN OSGR_CI_EASTING(gridref);
        ELSE
            RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END CASE;

END;
$$;