#!/bin/bash

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

# --------------------- define scenario ---------------------
# (1) 10 members, 1999-2019 (21 years) = standard
# (2) 10 members, 1999-2008 (10 years) = scenario2
# (3) 5 members, 1999-2019 (21 years)  = scenario3
# (4) 5 members, 1999-2008 (10 years)  = scenario4
iscenario=scenario3

for icounter in {0..4}; do
        echo $icounter
        imodel=${caseArray[$icounter]}
        inputDir=${dirArray[$icounter]}
        echo $imodel
        echo $inputDir
        for ivar in tas_2m; do
                echo $ivar
                finalFile=$ivar.S2S.$imodel.$iscenario
                echo $finalFile
                rm $finalFile
                find $inputDir -print | grep "\/$ivar\/" | grep "0[0-4]\.nc$" | sort > $finalFile
        done
done
