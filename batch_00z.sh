#!/bin/bash
#PBS -N cfsrGRIBtoNC_00z
#PBS -j oe
#PBS -M sglanvil@ucar.edu
#PBS -l select=1:ncpus=1:mpiprocs=1:mem=100GB
#PBS -A CESM0020
#PBS -l walltime=24:00:00
#PBS -q casper

module load ncl

## convert from .grb2 to .nc
for ifile in *00.grb2; do
        echo $ifile
        iname=$(sed -e 's/\.grb2//' <<< $ifile)
        echo $iname.nc
        if [ ! -f $iname.nc ]; then
                echo "file does not exist yet"
                ncl_convert2nc $ifile
        fi
        size=$(du -shb "$iname.nc" | cut -f1)
        if [ $size -lt 655000000 ]; then
                echo "file size too small"
                rm $iname.nc
                ncl_convert2nc $ifile
        fi
done

# update job name and ifile *00 loop to change from (00,06,12,18)
# location: /glade/scratch/sglanvil/NCEPCFSR/
# submit with command, on Cheyenne: qsubcasper batch_00z.sh
