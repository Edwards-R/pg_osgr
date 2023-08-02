# ci_northing

## Signature
    osgr_ci_northing(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the northing of

## Returns
An integer representation of the northing

## Explanation
Extracts the northing from the given grid reference, with the assumption that the grid reference is from the Channel Islands. Do not use directly, rely on `osgr_process_northing` which will do detection of datum automatically.

## Example