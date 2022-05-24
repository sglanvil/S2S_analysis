#!/bin/bash

module load ncl

## copy files from rda
#for iyear in {2011..2022}; do
#       echo $iyear
#       cp /glade/collections/rda/data/ds094.0/$iyear/*.pgrbf.* /glade/scratch/sglanvil/NCEPCFSv2/ 
#done

## untar files (just using forecast = 1hr)
for ifile in /glade/scratch/sglanvil/NCEPCFSv2/*.tar; do
        idate=$(sed -e 's/.*cdas1\.//' <<< $ifile | sed -e 's/\.pgrbf\.tar//')
        echo $idate
        tar -xvf $ifile
        rename "pgrbf01" "pgrbf01.$idate" *.pgrbf01.grib2
        rm *.pgrbf0[2-9].grib2
done

## convert from .grib2 to .nc
#for ifile in /glade/scratch/sglanvil/NCEPCFSv2/*.grib2; do
        #echo $ifile
        #ncl_convert2nc $ifile
#done

