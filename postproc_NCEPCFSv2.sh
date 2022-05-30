#!/bin/bash

# directory: /glade/scratch/sglanvil/NCEPCFSv2/

# There is a time issue because we are using the 06 hour forecasts.
# So you need to shift 06 hrs backwards.
# time issue: dd00=6am, dd06=12pm, dd12=6pm, dd18=12am
# need to shift: (dd-1)18=12am, dd00=6am, dd06=12pm, dd12=6pm = the daily avg

module load nco

date='20110401' # use first date available
endDate='20110403' # use last date-1 available

while [[ $date -le $endDate ]]; do
        # add if T_NCEPCFSv2 DNE or is too small...
        # echo $(date -d $date +%Y%m%d)
        date=$(date -d "$date + 1 day" +"%Y%m%d")
        datePrevious=$(date -d "$date - 1 day" +"%Y%m%d")
        echo "Running t="$date"; t-1="$datePrevious 
        size=$(du -shb pr_sfc_NCEPCFSv2.${date}.dailyAvg.nc | cut -f1)
        echo "Size of last variable file="$size 
        # check if last variable file exists (in this case, pr_sfc)
        if [[ ! -f pr_sfc_NCEPCFSv2.${date}.dailyAvg.nc || $size -lt 260000 ]]; then
                ncecat -O cdas1.t18z.pgrbf06.${datePrevious}.nc cdas1.t00z.pgrbf06.${date}.nc cdas1.t06z.pgrbf06.${date}.nc cdas1.t12z.pgrbf06.${date}.nc cdas1.pgrbf06.${date}.6hrly.nc
                ncwa -O -a record cdas1.pgrbf06.${date}.6hrly.nc cdas1.pgrbf06.${date}.dailyAvg.nc
                # ----- Temperature (lon,lat,p) = TMP_P0_L100_GLL0 (K)
                ncks -O -v TMP_P0_L100_GLL0,lv_ISBL0,lat_0,lon_0 cdas1.pgrbf06.${date}.dailyAvg.nc T_NCEPCFSv2.${date}.dailyAvg.nc
                # ----- 2m Temperature (lon,lat) = TMP_P0_L103_GLL0 (K)
                ncks -O -v TMP_P0_L103_GLL0,lat_0,lon_0 cdas1.pgrbf06.${date}.dailyAvg.nc tas_2m_NCEPCFSv2.${date}.dailyAvg.nc
                # ----- Surface Total Precipiation Rate (lon, lat) = PRATE_P8_L1_GLL0_avg (kg/m2/s)
                ncks -O -v PRATE_P8_L1_GLL0_avg,lat_0,lon_0 cdas1.pgrbf06.${date}.dailyAvg.nc pr_sfc_NCEPCFSv2.${date}.dailyAvg.nc
        fi
        echo "done"
done

# concatenate all date files, into single time series, making time the new record dimension
ncecat -O -u time T_NCEPCFSv2.[0-9]*.dailyAvg.nc T_NCEPCFSv2.ALL.dailyAvg.nc
ncecat -O -u time tas_2m_NCEPCFSv2.[0-9]*.dailyAvg.nc tas_2m_NCEPCFSv2.ALL.dailyAvg.nc
ncecat -O -u time pr_sfc_NCEPCFSv2.[0-9]*.dailyAvg.nc pr_sfc_NCEPCFSv2.ALL.dailyAvg.nc
