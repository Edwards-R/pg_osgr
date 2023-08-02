# process_easting

## Signature
    osgr_process_easting(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the easting of

## Returns
An integer representation of the easting

## Explanation
Extracts the easting of a given grid reference, automatically detecting the datum.

## Example