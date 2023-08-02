-- Converts an easting, northing, and accuracy into a GB OSGR

CREATE OR REPLACE FUNCTION osgr_to_gb(
        easting INT,
        northing INT,
        accuracy INT
    )
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$

DECLARE
    l1 INT;
    l2 INT;
    
    padLength INT;

BEGIN
    l1 = (19-(northing/100000))-(19-(northing/100000))%5+((easting/100000)+10)/5;
    l2 = (19-(northing/100000))*5%25+((easting/100000)%5);

    IF (l1>7) THEN
        l1 = l1+1;
    END IF;

    IF l2>7 THEN
        l2 = l2+1;
    END IF;

    padLength = log(accuracy);

    RETURN CHR(ASCII('A') + l1)||CHR(ASCII('A') + l2)||lpad(((easting%100000)/accuracy)::text, 5-padLength, '0')||lpad(((northing%100000)/accuracy)::text, 5-padLength, '0');
END;
$$;