#!/bin/bash
#PBS -N CFSRpostproc
#PBS -j oe
#PBS -M sglanvil@ucar.edu
#PBS -l select=1:ncpus=1:mpiprocs=1:mem=100GB
#PBS -A CESM0020
#PBS -l walltime=24:00:00
#PBS -q casper

# submit with command: qsubcasper postproc_NCEPCFSR.sh

# directory: /glade/scratch/sglanvil/NCEPCFSR/

# There is a time issue because we are using the 06 hour forecasts.
# So you need to shift 06 hrs backwards.
# time issue: dd00=6am, dd06=12pm, dd12=6pm, dd18=12am
# need to shift: (dd-1)18=12am, dd00=6am, dd06=12pm, dd12=6pm = the daily avg

module load nco

date='19990101' # use first date available
endDate='20101230' # use last date-1 available

while [[ $date -le $endDate ]]; do
        # echo $(date -d $date +%Y%m%d)
        date=$(date -d "$date + 1 day" +"%Y%m%d")
        datePrevious=$(date -d "$date - 1 day" +"%Y%m%d")
        echo "Running t="$date"; t-1="$datePrevious 

        # if the variale files exist, then measure the sizes
        if [[ -f pr_sfc_NCEPCFSR.${date}.dailyAvg.nc && -f tas_2m_NCEPCFSR.${date}.dailyAvg.nc && -f T_NCEPCFSR.${date}.dailyAvg.nc ]]; then
                size_pr_sfc=$(du -shb pr_sfc_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
                size_tas_2m=$(du -shb tas_2m_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
                size_T=$(du -shb T_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
        # else, create all of them
        else
                echo "missing file"
                ncecat -O pgbh06.gdas.${datePrevious}18.nc pgbh06.gdas.${date}00.nc pgbh06.gdas.${date}06.nc pgbh06.gdas.${date}12.nc pgbh06.gdas.${date}.6hrly.nc
                ncwa -O -a record pgbh06.gdas.${date}.6hrly.nc pgbh06.gdas.${date}.dailyAvg.nc
                # ----- Temperature (lon,lat,p) = TMP_P0_L100_GLL0 (K)
                ncks -O -v TMP_P0_L100_GLL0,lv_ISBL0,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc T_NCEPCFSR.${date}.dailyAvg.nc
                # ----- 2m Temperature (lon,lat) = TMP_P0_L103_GLL0 (K)
                ncks -O -v TMP_P0_L103_GLL0,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc tas_2m_NCEPCFSR.${date}.dailyAvg.nc
                # ----- Surface Total Precipiation Rate (lon, lat) = PRATE_P8_L1_GLL0_avg (kg/m2/s)
                ncks -O -v PRATE_P8_L1_GLL0_avg,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc pr_sfc_NCEPCFSR.${date}.dailyAvg.nc
                size_pr_sfc=$(du -shb pr_sfc_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
                size_tas_2m=$(du -shb tas_2m_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
                size_T=$(du -shb T_NCEPCFSR.${date}.dailyAvg.nc | cut -f1)
        fi

        # if the sizes are off, recreate all files
        if [[ $size_pr_sfc -lt 260000 || $size_tas_2m -lt 260000 || $size_T -lt 9640000 ]]; then
                echo "incorrect size"
                ncecat -O pgbh06.gdas.${datePrevious}18.nc pgbh06.gdas.${date}00.nc pgbh06.gdas.${date}06.nc pgbh06.gdas.${date}12.nc pgbh06.gdas.${date}.6hrly.nc
                ncwa -O -a record pgbh06.gdas.${date}.6hrly.nc pgbh06.gdas.${date}.dailyAvg.nc
                # ----- Temperature (lon,lat,p) = TMP_P0_L100_GLL0 (K)
                ncks -O -v TMP_P0_L100_GLL0,lv_ISBL0,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc T_NCEPCFSR.${date}.dailyAvg.nc
                # ----- 2m Temperature (lon,lat) = TMP_P0_L103_GLL0 (K)
                ncks -O -v TMP_P0_L103_GLL0,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc tas_2m_NCEPCFSR.${date}.dailyAvg.nc
                # ----- Surface Total Precipiation Rate (lon, lat) = PRATE_P8_L1_GLL0_avg (kg/m2/s)
                ncks -O -v PRATE_P8_L1_GLL0_avg,lat_0,lon_0 pgbh06.gdas.${date}.dailyAvg.nc pr_sfc_NCEPCFSR.${date}.dailyAvg.nc
        fi
done

echo "make final time series files"
# concatenate all date files, into single time series, making time the new record dimension
ncecat -O -u time T_NCEPCFSR.[0-9]*.dailyAvg.nc T_NCEPCFSR.ALL.dailyAvg.nc
ncecat -O -u time tas_2m_NCEPCFSR.[0-9]*.dailyAvg.nc tas_2m_NCEPCFSR.ALL.dailyAvg.nc
ncecat -O -u time pr_sfc_NCEPCFSR.[0-9]*.dailyAvg.nc pr_sfc_NCEPCFSR.ALL.dailyAvg.nc
echo "done"
