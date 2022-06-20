#!/bin/bash

# ------------------ USER SPECIFY ------------------
iscenario=standard 
# choose: standard, scenario2, scenario3, or scenario4
# --------------------------------------------------
# (1) 10 members, 1999-2019 (21 years) = standard
# (2) 10 members, 1999-2008 (10 years) = scenario2
# (3) 5 members, 1999-2019 (21 years)  = scenario3
# (4) 5 members, 1999-2008 (10 years)  = scenario4

caseArray=(cesm2cam6v2 \
cesm2cam6climoATMv2 \
cesm2cam6climoLNDv2 \
cesm2cam6climoOCNv2 \
cesm2cam6climoOCNclimoATMv2)

dirArray=(/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTS/ \
/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTSclimoATM/postprocess/ \
/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTSclimoLND/postprocess/ \
/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTSclimoOCN/postprocess/ \
/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTSclimoOCNclimoATM/postprocess/)

for icounter in {0..4}; do # ---------------- Loop through all 5 experiments
        echo $icounter
        imodel=${caseArray[$icounter]}
        inputDir=${dirArray[$icounter]}
        echo $imodel
        echo $inputDir
        for ivar in tas_2m; do # ------------ Choose variables (tas_2m, pr_sfc, T, etc.)
                echo $ivar
                finalFile=$ivar.S2S.$imodel.$iscenario
                echo $finalFile
                rm $finalFile
                if [[ $iscenario == standard ]]; then
                        echo standard
                        find $inputDir -print | grep "\/$ivar\/" | grep "0[0-9]\.nc$" | sort > $finalFile
                        sed -i '/202[0,1,2]/d' $finalFile
                fi
                if [[ $iscenario == scenario2 ]]; then
                        echo scenario2
                        find $inputDir -print | grep "\/$ivar\/" | grep "0[0-9]\.nc$" | sort > $finalFile
                        sed -i '/2009/d' $finalFile
                        sed -i '/201[0-9]/d' $finalFile
                        sed -i '/202[0-2]/d' $finalFile
                fi
                if [[ $iscenario == scenario3 ]]; then
                        echo scenario3
                        find $inputDir -print | grep "\/$ivar\/" | grep "0[0-4]\.nc$" | sort > $finalFile
                        sed -i '/202[0,1,2]/d' $finalFile
                fi
                if [[ $iscenario == scenario4 ]]; then
                        echo scenario4
                        find $inputDir -print | grep "\/$ivar\/" | grep "0[0-4]\.nc$" | sort > $finalFile
                        sed -i '/2009/d' $finalFile
                        sed -i '/201[0-9]/d' $finalFile
                        sed -i '/202[0-2]/d' $finalFile
                fi
        done
done

#imodel=cesm2cam6v2
#inputDir=/glade/campaign/cesm/development/cross-wg/S2S/CESM2/S2SHINDCASTS/

#imodel=70Lwaccm6
#inputDir=/gpfs/csfs1/cesm/collections/S2Sfcst/POSTPROC/



