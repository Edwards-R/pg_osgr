-- Finds the accuracy of the provided grid reference in datum units (metres)

CREATE OR REPLACE FUNCTION osgr_accuracy(
        gridref TEXT
    )
    RETURNS INT
    LANGUAGE plpgsql
AS $$

DECLARE
    input TEXT;
    refLength INT;

BEGIN
    input=(regexp_matches(Upper(gridref), '^([A-H|J-Z]{1,2}(?:[0-9][0-9])+)(?:(?:[NS][EW])|[A-D])?$'))[1];
    IF input IS NULL THEN
        RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END IF;

    input = (regexp_matches(input, '[0-9]+'))[1];
    refLength = LENGTH(input)/2;

    IF refLength>5 THEN
        refLength = 5;
    END IF;

    RETURN 1*10^(5-refLength);
END;
$$;