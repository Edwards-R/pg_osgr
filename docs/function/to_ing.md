# to_ing

## Signature
    osgr_to_ing(
        easting INT,
        northing INT,
        accuracy INT
    )
    RETURNS TEXT

## Arguments

### easting
The easting to create the grid reference for

### northing
The northing to create the grid reference for

### accuracy
The accuracy to create the grid reference at

## Returns
An OS grid reference in the ING datum with the provided parameters

## Explanation
Do not use directly, rely on `osgr_to_gridref` as it handles datums/checking automatically. Constructs an OS grid reference in the ING datum with the provided parameters.

## Example