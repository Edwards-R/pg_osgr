-- Attempts to find the datum of a provided grid reference
-- Can tell the difference between Great Britain (GB) (27700), Irish National Grid (ING) (29901), and Channel Islands (CI) (32630)
-- Returns the primary key of the found datum

CREATE OR REPLACE FUNCTION osgr_find_datum(
        gridref TEXT
    )
    RETURNS INT
    LANGUAGE plpgsql
AS $$

DECLARE
    letters TEXT;

BEGIN
    letters = (regexp_matches(Upper(gridref), '^([A-H|J-Z]{1,2}(?:[0-9][0-9])+)(?:(?:[NS][EW])|[A-D])?$'))[1];

    IF (letters IS NULL) THEN
        RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END IF;

    letters = (regexp_matches(Upper(gridref), '^([W][AV])'))[1];

    IF (letters IS NOT NULL) THEN
        RETURN 32630;
    END IF;

    letters = (regexp_matches(Upper(gridref), '^([A-H|J-Z]{2}(?:[0-9][0-9])+)'))[1];

    IF (letters IS NOT NULL) THEN
        RETURN 27700;
    END IF;

    RETURN 29901;

END;$$;