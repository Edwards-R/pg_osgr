-- Converts an easting, northing, and accuracy into an ING OSGR

CREATE OR REPLACE FUNCTION osgr_to_ing(
        easting INTEGER,
        northing INTEGER,
        accuracy INTEGER
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$

DECLARE
    l1 INT;
    padLength INT;

BEGIN
    l1 = (4-(northing/100000))*5%25+((easting/100000)%5);

    IF (l1>7) THEN
        l1 = l1+1;
    END IF;

    padLength = log(accuracy);

    RETURN CHR(ASCII('A') + l1)||lpad(((easting%100000)/accuracy)::text, 5-padLength, '0')||lpad(((northing%100000)/accuracy)::text, 5-padLength, '0');

END;
$$;