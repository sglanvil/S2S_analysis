#!/bin/bash

module load ncl

## copy files from rda (just forecast = 06 hour)
for iyear in {1999..2010}; do
       echo $iyear
       cp /glade/collections/rda/data/ds093.0/$iyear/pgbh06* /glade/scratch/sglanvil/NCEPCFSR/
done

## untar files
#for ifile in /glade/scratch/sglanvil/NCEPCFSR/*.tar; do
#        echo $ifile
#        tar -xvf $ifile
#done

## convert from .grb2 to .nc
#for ifile in /glade/scratch/sglanvil/NCEPCFSR/*.grb2; do
#       echo $ifile
#       ncl_convert2nc $ifile
#done
#rm *.grb2


