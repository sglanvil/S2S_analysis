#!/bin/bash
# The "all years" files are too big, so chunk them down, then interpolate with matlab

module load nco

# 2010-01-01 is missing/corrupt in rda source, so copy 2010-01-02 for now
cp pr_sfc_NCEPCFSR.20100102.dailyAvg.nc pr_sfc_NCEPCFSR.20100101.dailyAvg.nc
cp tas_2m_NCEPCFSR.20100102.dailyAvg.nc tas_2m_NCEPCFSR.20100101.dailyAvg.nc
cp T_NCEPCFSR.20100102.dailyAvg.nc T_NCEPCFSR.20100101.dailyAvg.nc

# 1999-01-01 is missing/corrupt in rda source, so copy 1999-01-02 for now
cp pr_sfc_NCEPCFSR.19990102.dailyAvg.nc pr_sfc_NCEPCFSR.19990101.dailyAvg.nc
cp tas_2m_NCEPCFSR.19990102.dailyAvg.nc tas_2m_NCEPCFSR.19990101.dailyAvg.nc
cp T_NCEPCFSR.19990102.dailyAvg.nc T_NCEPCFSR.19990101.dailyAvg.nc

for iyear in {1999..2010}; do
        echo $iyear 
        ncecat -O -u time pr_sfc_NCEPCFSR.${iyear}*.dailyAvg.nc pr_sfc_NCEPCFSR.dailyAvg.${iyear}.nc
        ncecat -O -u time tas_2m_NCEPCFSR.${iyear}*.dailyAvg.nc tas_2m_NCEPCFSR.dailyAvg.${iyear}.nc
        ncecat -O -u time -d lv_ISBL0,84000.,86000. T_NCEPCFSR.${iyear}*.dailyAvg.nc T_850_NCEPCFSR.dailyAvg.${iyear}.nc
done
