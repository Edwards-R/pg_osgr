# to_gridref

## Signature
    osgr_to_gridref(
        easting INT,
        northing INT,
        accuracy INT,
        datum INT
    )
    RETURNS TEXT

## Arguments

### easting
The easting to create the grid reference for

### northing
The northing to create the grid reference for

### accuracy
The accuracy to create the grid reference at

### datum
The datum to create the grid reference with

## Returns
An OS grid reference in the appropriate datum with the provided parameters

## Explanation
Use this rather than specific datum functions. Constructs an OS grid reference in the provided datum with the provided parameters. Rejects if the datum is not one provided.

## Example