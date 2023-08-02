# process_northing

## Signature
    osgr_process_northing(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the northing of

## Returns
An integer representation of the northing

## Explanation
Extracts the northing of a given grid reference, automatically detecting the datum.

## Example