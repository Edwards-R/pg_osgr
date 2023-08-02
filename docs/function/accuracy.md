# accuracy

## Signature
    osgr_accuracy(
        gridref TEXT
    )
    RETURNS INT

## Arguments

### gridref
The OS grid reference to find the accuracy of


## Returns
The resolution of the provided grid reference. Limited to powers of 10

## Explanation
While more accurately considered precision, `precision` is a reserved word in `postgreSQL`. Accuracy is used as a fallback. Only operates in powers of 10, no quadrats support available.

## Example