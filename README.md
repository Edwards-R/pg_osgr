# OS Grid Reference Handling for PostgreSQL & PostGIS

***

## Warning
This is a passion project from a dev who is learning on the fly. So far as I can tell it works, but ***please*** don't use this in anything critical without extensive testing.

***

## What it does
This library is designed to handle the conversion between Ordanance Survey Grid References and *cartesian* easting/northing/accuracy/datum information.

It is intended to work with PostgreSQL and PostGIS.

Why *accuracy* and not *precision*? Because *precision* is a reserved term in postgres. *Accuracy* is close enough and not reserved, so I use it.

Datums follow the EPSG codes as in PostGIS

Sub 1 m resolution is **not supported**

 Invalid grid references *should* return an error, at least they have so far...

***

## What does it cover
The library is able to handle England, Scotland, Wales, Ireland (using the 29901 datum) and the Channel Islands

***

## Installation

Copy the code from osgr--0.0.1.sql into postgres and run it. It will attempt to install into the `public` schema. Remove all references to public from the code if you want to specify where to put it. I know this isn't perfect, but see end section on further development.

***

## How to use it
The main use of this library to is convert between ENAD (Easting, Northing, Accuracy, Datum) format and OS Grid references.

### Grid reference to ENAD
This requires four calls

* **Calculate Easting**

        osgr_process_easting(gridref::Text) ::Int

    This takes a textual grid reference and returns the **minimum** cartesian easting of the grid reference.

    *Example*

        osgr_process_easting('SV470275') > 47000

* **Calculate Northing**

        osgr_process_northing(gridref::Text) ::Int

    This takes a textual grid reference and returns the **minimum** cartesian northing of the grid reference.

    *Example*

        osgr_process_northing('SV470275') > 27500

* **Find Accuracy**

        osgr_accuracy(gridref::Text) ::Int

    This takes a textual grid reference and returns the number of datum units (metres if this is used as intended) that each grid cell represents.

    *Example*

        osgr_accuracy('SV470275') > 100


* **Find Datum**

        osgr_find_datum(gridref::Text) ::Int

    This takes a textual grid reference and returns the datum it associates with that grid reference. Invalid grid references should throw an error.

    *Example*

        osgr_find_datum('SV470275') > 27700

***


### ENAD to Grid Reference

This is a single call

* **Calculate Grid Reference**

        osgr_to_gridref(easting::Int, northing::Int, accuracy::Int, datum::Int) ::Text

    This takes in ENAD data and returns an Ordnance Survey format grid reference

    *Example*

        osgr_to_gridref(47000, 27500, 100, 27700) > SV470275

***

## Further Development
Maybe. Learning how to bundle the code into an extension and then learning how to manage updates, install schema etc is certainly on the list, but I'm out of time on this project and need to move on to the next fire.