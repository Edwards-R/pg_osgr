# find_datum

## Signature
    osgr_find_datum(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the datum of

## Returns
EPSG code of the detected datum

## Explanation
Scans for CI datum (W*X*), Irish datum (*A*), then GB datum (*AA*). Returns the standard EPSG code used by `postGIS` as a result.

## Example