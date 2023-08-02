-- Finds the easting of a provided Channel Islands grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_ci_easting(
        gridref TEXT
    )
    RETURNS INT
    LANGUAGE plpgsql
AS $$

DECLARE
    letters TEXT;
    numbers TEXT;
    letterA INT;
    letterB INT;
    numUnpad TEXT;
    numPad TEXT;
    letterConverted TEXT;

BEGIN
    letters = (regexp_matches(Upper(gridref), '^([A-H|J-Z]{2}(?:[0-9][0-9])+)(?:(?:[NS][EW])|[A-D])?$'))[1];
    IF letters IS NULL THEN
        RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END IF;
    letters = (regexp_matches(letters, '[A-Z]+'))[1];
    numbers = (regexp_matches(gridref, '[0-9]+'))[1];

    letterA = ASCII(letters)-ASCII('A');
    IF letterA>7 THEN
        letterA=letterA-1;
    END IF;

    numUnpad = LEFT(LEFT(numbers, LENGTH(numbers)/2),5);

    numPad = numUnpad||left('00000000', 5-LENGTH(numUnpad));

    letterConverted = 5;

    RETURN letterConverted||numPad;
END;
$$;