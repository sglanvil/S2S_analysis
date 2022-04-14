% April 14, 2022
% NOTES: currently we cutoff at 2015 or 2009
% NOTES: precip in obs is for mm/day while it is in mm/s in model
clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
varName='tas_2m';

simList={'cesm2cam6climoATMv2','cesm2cam6climoOCNclimoATMv2',...
    'cesm2cam6climoOCNv2','cesm2cam6v2'};

seasonList={'DJF'};
% ------------------------- SPECIFY ABOVE -------------------------

divideObsBy=1;
if strcmp(varName,'pr')==1
    divideObsBy=86400;
end

timeList={'daily'};
for isim=4 % 1:length(simList)
    simName=simList{isim};
    for itime=1:length(timeList)
        timeAvg=timeList{itime};
        for iseason=1:length(seasonList)
            season=seasonList{iseason};
            disp({simName timeAvg season})
            
            if contains(simName,'CESM1')==1
                forecastDay='Wed';
            else
                forecastDay='Mon';
            end

            ncSave=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_%sseason_%s_%s_s2s_data.nc',varName,season,timeAvg,simName);
%             ncSave=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_%sseason_%sweeks_%s_s2s_data.nc',varName,season,timeAvg,simName);
%             ncSave=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_ALLseason_%sweeks_%s_s2s_data.nc',varName,timeAvg,simName);
            fil=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_anom_%s_s2s_data.nc',varName,simName);
            filObs=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_anom_CPC_%s_data.nc',varName,forecastDay);

            anomObs=ncread(filObs,'anom')/divideObsBy; 
            anom=ncread(fil,'anom'); 
            lat=ncread(fil,'lat');
            lon=ncread(fil,'lon');
            time=ncread(fil,'time');
            timeObs=ncread(filObs,'time');
            starttime=datetime(time,'ConvertFrom','datenum','Format','dd-MMM-yyyy');
            anom(:,:,:,year(starttime)>2015)=[]; % ------- SPECIFY -------
            starttime(year(starttime)>2015)=[]; % ------- SPECIFY -------
            
            starttimeObs=datetime(timeObs,'ConvertFrom','datenum','Format','dd-MMM-yyyy');
            anomObs(:,:,:,year(starttimeObs)>2015)=[]; % ------- SPECIFY -------
            starttimeObs(year(starttimeObs)>2015)=[]; % ------- SPECIFY -------

            starttime(1)
            starttimeObs(1)
            
            clear anom_timeChunk anomObs_timeChunk
            icounter=0;
            if strcmp(timeAvg,'double')==1
                for timeChunk=[1 3 5]
                    icounter=icounter+1;
                    anom_timeChunk(:,:,icounter,:)=squeeze(nanmean(...
                        anom(:,:,(timeChunk-1)*7+1+1:(timeChunk-1)*7+14+1,:),3)); % note +1 at the end (Lantao)
                    anomObs_timeChunk(:,:,icounter,:)=squeeze(nanmean(...
                        anomObs(:,:,(timeChunk-1)*7+1:(timeChunk-1)*7+14,:),3));
                end
            end
            if strcmp(timeAvg,'single')==1
                for timeChunk=1:6
                    icounter=icounter+1;
                    anom_timeChunk(:,:,icounter,:)=squeeze(nanmean(...
                        anom(:,:,(timeChunk-1)*7+1+1:(timeChunk-1)*7+7+1,:),3)); % note +1 at the end (Lantao)
                    anomObs_timeChunk(:,:,icounter,:)=squeeze(nanmean(...
                        anomObs(:,:,(timeChunk-1)*7+1:(timeChunk-1)*7+7,:),3));
                end
            end
            if strcmp(timeAvg,'daily')==1
                anom_timeChunk=anom;
                anomObs_timeChunk=anomObs;
            end

            if strcmp(season,'DJF')==1
                amonth=1; bmonth=2; cmonth=12;
            elseif strcmp(season,'MAM')==1
                amonth=3; bmonth=4; cmonth=5;
            elseif strcmp(season,'JJA')==1
                amonth=6; bmonth=7; cmonth=8;
            elseif strcmp(season,'SON')==1
                amonth=9; bmonth=10; cmonth=11;
            end
            
            size(anom_timeChunk)
            size(anomObs_timeChunk)
            % FIND WHERE INITIALIZATIONS MATCH CHOSEN SEASON
            anom_timeChunk=squeeze(anom_timeChunk(:,:,:,...
                month(starttime)==amonth | month(starttime)==bmonth | month(starttime)==cmonth));
            anomObs_timeChunk=squeeze(anomObs_timeChunk(:,:,:,...
                month(starttimeObs)==amonth | month(starttimeObs)==bmonth | month(starttimeObs)==cmonth));
            size(anom_timeChunk)
            size(anomObs_timeChunk)
            
            clear ACC_timeChunk
            for timeChunk=1:size(anomObs_timeChunk,3) % user lead in obs (45) instead of model (46)
                anomFF=squeeze(anom_timeChunk(:,:,timeChunk,:));
                anomAA=squeeze(anomObs_timeChunk(:,:,timeChunk,:));
                a=(anomFF.*anomAA);
                b=(anomFF).^2;
                c=(anomAA).^2;
                aTM=squeeze(nanmean(a,3)); % calculate time means (TM)
                bTM=squeeze(nanmean(b,3));
                cTM=squeeze(nanmean(c,3));
                ACC_timeChunk(:,:,timeChunk)=aTM./sqrt(bTM.*cTM);
            end
            timeChunk=1:size(ACC_timeChunk,3);

            % ------------------------ save at netcdf ------------------------
            ncid=netcdf.create(ncSave,'NC_WRITE');
            %Define the dimensions
            dimidlon = netcdf.defDim(ncid,'lon',length(lon));
            dimidlat = netcdf.defDim(ncid,'lat',length(lat));
            dimidtimeChunk = netcdf.defDim(ncid,'timeChunk',length(timeChunk));
            %Define IDs for the dimension variables (pressure,time,varsitude,...)
            lon_ID=netcdf.defVar(ncid,'lon','double',[dimidlon]);
            lat_ID=netcdf.defVar(ncid,'lat','double',[dimidlat]);
            timeChunk_ID=netcdf.defVar(ncid,'timeChunk','double',[dimidtimeChunk]);
            ACC_ID = netcdf.defVar(ncid,'ACC','double',[dimidlon dimidlat dimidtimeChunk]);
            %We are done defining the NetCdf
            netcdf.endDef(ncid);
            %Then store the dimension variables in
            netcdf.putVar(ncid,lon_ID,lon);
            netcdf.putVar(ncid,lat_ID,lat);
            netcdf.putVar(ncid,timeChunk_ID,timeChunk);
            netcdf.putVar(ncid,ACC_ID,ACC_timeChunk);
            %We're done, close the netcdf
            netcdf.close(ncid)
        end
    end
end



