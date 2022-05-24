#!/bin/bash

module load ncl

## copy files from rda
for iyear in {2011..2022}; do
        echo $iyear
        cp /glade/collections/rda/data/ds094.0/$iyear/*.pgrbf.* /glade/scratch/sglanvil/NCEPCFSv2/
done

## untar files
for ifile in /glade/scratch/sglanvil/NCEPCFSv2/*.tar; do
        echo $ifile
        tar -xvf $ifile
        rm $ifile
done
rm *.pgrbf0[2-9].*grib2

## convert from .grib2 to .nc
for ifile in /glade/scratch/sglanvil/NCEPCFSv2/*.grib2; do
        echo $ifile
        ncl_convert2nc $ifile
done
rm *.grib2

