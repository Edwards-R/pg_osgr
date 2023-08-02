# ing_northing

## Signature
    osgr_ing_northing(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the northing of

## Returns
An integer representation of the northing

## Explanation
Extracts the northing from the given grid reference, with the assumption that the grid reference uses the Irish National Grid. Do not use directly, rely on `osgr_process_easting` which will do detection of datum automatically.

## Example