# ci_easting

## Signature
    osgr_ci_easting(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the easting of

## Returns
An integer representation of the easting

## Explanation
Extracts the easting from the given grid reference, with the assumption that the grid reference is from the Channel Islands. Do not use directly, rely on `osgr_process_easting` which will do detection of datum automatically.

## Example