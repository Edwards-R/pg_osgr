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
$$;-- A handler function that returns the easting of a provided grid ref in the determined datum (see find_datum for more details)

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
$$;-- A handler function that returns the northing of a provided grid ref in the determined datum (see find_datum for more details)

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
$$;-- Attempts to find the datum of a provided grid reference
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

END;$$;-- Converts an easting, northing, and accuracy into a GB OSGR

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
$$;-- Converts an easting, northing, and accuracy into an ING OSGR

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
$$;-- Finds the easting of a provided Great Britain grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_gb_easting(
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

    letterA = ASCII(LEFT(letters,1))-ASCII('A');
    IF letterA>7 THEN
        letterA=letterA-1;
    END IF;

    letterB = ASCII(RIGHT(letters,1))-ASCII('A');
    IF letterB>7 THEN
        letterB=letterB-1;
    END IF;

    numUnpad = LEFT(LEFT(numbers, LENGTH(numbers)/2),5);

    numPad = numUnpad||left('00000000', 5-LENGTH(numUnpad));

    letterConverted = (((letterA-2)%5)*5)+letterB%5;

    RETURN letterConverted||numPad;
END;
$$;-- Finds the northing of a provided Great Britain grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_gb_northing(
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

    letterA = ASCII(LEFT(letters,1))-ASCII('A');
    IF letterA>7 THEN
        letterA=letterA-1;
    END IF;

    letterB = ASCII(RIGHT(letters,1))-ASCII('A');
    IF letterB>7 THEN
        letterB=letterB-1;
    END IF;

    numUnpad = LEFT(RIGHT(numbers, LENGTH(numbers)/2),5);

    numPad = numUnpad||left('00000000', 5-LENGTH(numUnpad));

    letterConverted = (19-Floor(letterA/5)*5)-Floor(letterB/5);

    RETURN letterConverted||numPad;
END;
$$;-- Finds the easting of a provided Channel Islands grid reference in datum units (m)

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
$$;-- Finds the northing of a provided Irish National Grid grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_ing_northing(
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
    letters = (regexp_matches(Upper(gridref), '^([A-H|J-Z]{1}(?:[0-9][0-9])+)(?:(?:[NS][EW])|[A-D])?$'))[1];
    IF letters IS NULL THEN
        RAISE EXCEPTION 'Invalid gridref supplied: %', gridref;
    END IF;
    letters = (regexp_matches(letters, '[A-Z]+'))[1];
    numbers = (regexp_matches(gridref, '[0-9]+'))[1];

    letterA = ASCII(LEFT(letters,1))-ASCII('A');
    IF letterA>7 THEN
        letterA=letterA-1;
    END IF;


    numUnpad = LEFT(RIGHT(numbers, LENGTH(numbers)/2),5);

    numPad = numUnpad||left('00000000', 5-LENGTH(numUnpad));

    letterConverted = 4-Floor(letterA/5);

    RETURN letterConverted||numPad;
END;
$$;-- Finds the northing of a provided Channel Islands grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_ci_northing(
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

    letterA = ASCII(LEFT(letters,1))-ASCII('A');
    IF letterA>7 THEN
        letterA=letterA-1;
    END IF;

    numUnpad = LEFT(RIGHT(numbers, LENGTH(numbers)/2),5);

    numPad = numUnpad||left('00000000', 5-LENGTH(numUnpad));

    IF letters='WA' THEN
        letterConverted=55;
    ELSE
        letterConverted=54;
    END IF;

    RETURN letterConverted||numPad;
END;
$$;-- Converts an easting, northing, and accuracy into an CI OSGR

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
$$;-- Finds the accuracy of the provided grid reference in datum units (metres)

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
$$;-- Finds the easting of a provided Irish National Grid grid reference in datum units (m)

CREATE OR REPLACE FUNCTION osgr_ing_easting(
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
    letters = (regexp_matches(Upper(gridref), '^([A-H|J-Z]{1}(?:[0-9][0-9])+)(?:(?:[NS][EW])|[A-D])?$'))[1];
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

    letterConverted = letterA%5;

    RETURN letterConverted||numPad;
END;$$;