-- Converts an easting, northing, and accuracy into an CI OSGR

CREATE OR REPLACE FUNCTION osgr_to_ci(
        easting INT,
        northing INT,
        accuracy INT
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$

DECLARE
    l1 INT;
    c TEXT;

    padLength INT;

BEGIN
    IF northing/100000 = 55 THEN
        c = 'WA';
    ELSE
        c = 'WV';
    END IF;

    padLength = log(accuracy);

    RETURN c||lpad(((easting%100000)/accuracy)::text, 5-padLength, '0')||lpad(((northing%100000)/accuracy)::text, 5-padLength, '0');

END;
$$;