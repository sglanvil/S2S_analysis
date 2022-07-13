clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
varName='tas_2m';
caseList={'cesm2cam6v2','cesm2cam6climoATMv2','cesm2cam6climoLNDv2',...
    'cesm2cam6climoOCNv2','cesm2cam6climoOCNclimoATMv2'};
scenarioList={'scenario1','scenario2','scenario3','scenario4'};
season='DJF';
timeAvg='daily';
forecastDay='Mon';
% ------------------------- SPECIFY ABOVE -------------------------

divideObsBy=1;
if strcmp(varName,'pr_sfc')==1
    divideObsBy=86400; % OBS (mm/day) vs MODEL (mm/s)
end

for iscenario=1:length(scenarioList)
    scenarioName=scenarioList{iscenario};
    for icase=1:length(caseList)
        caseName=caseList{icase};
        disp({scenarioName caseName})
        ncSave=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/data/%s_ACC_%sseason_%s_%s.%s_s2s_data.nc',...
            varName,season,timeAvg,caseName,scenarioName);
        fil=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/data/%s_anom_%s.%s_s2s_data.nc',...
            varName,caseName,scenarioName);
        filOBS=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_anom_CPC_%s_data.nc',...
            varName,forecastDay);
        anomOBS=ncread(filOBS,'anom')/divideObsBy; 
        anom=ncread(fil,'anom'); 
        lat=ncread(fil,'lat');
        lon=ncread(fil,'lon');
        time=ncread(fil,'time');
        timeOBS=ncread(filOBS,'time');
        starttime=datetime(time,'ConvertFrom','datenum','Format','dd-MMM-yyyy');
        starttimeOBS=datetime(timeOBS,'ConvertFrom','datenum','Format','dd-MMM-yyyy');
        
        anom=anom(:,:,:,starttime>=starttimeOBS(1) & starttime<=starttimeOBS(end));
        anomOBS=anomOBS(:,:,:,starttimeOBS>=starttime(1) & starttimeOBS<=starttime(end));
        starttime=starttime(starttime>=starttimeOBS(1) & starttime<=starttimeOBS(end));
        starttimeOBS=starttimeOBS(starttimeOBS>=starttime(1) & starttimeOBS<=starttime(end));

        [starttime(1) starttimeOBS(1)]
        [starttime(end) starttimeOBS(end)]
        
        if strcmp(season,'DJF')==1
            amonth=1; bmonth=2; cmonth=12;
        elseif strcmp(season,'MAM')==1
            amonth=3; bmonth=4; cmonth=5;
        elseif strcmp(season,'JJA')==1
            amonth=6; bmonth=7; cmonth=8;
        elseif strcmp(season,'SON')==1
            amonth=9; bmonth=10; cmonth=11;
        end

        size(anom)
        size(anomOBS)
        % ------------------ find where initializations match user-specified season
        anom=squeeze(anom(:,:,:,...
            month(starttime)==amonth | month(starttime)==bmonth | month(starttime)==cmonth));
        anomOBS=squeeze(anomOBS(:,:,:,...
            month(starttimeOBS)==amonth | month(starttimeOBS)==bmonth | month(starttimeOBS)==cmonth));
        size(anom)
        size(anomOBS)

        clear ACC
        for ilead=1:size(anomOBS,3) % user lead in obs (45) instead of model (46)
            anomFF=squeeze(anom(:,:,ilead,:));
            anomAA=squeeze(anomOBS(:,:,ilead,:));
            a=(anomFF.*anomAA);
            b=(anomFF).^2;
            c=(anomAA).^2;
            aTM=squeeze(nanmean(a,3)); % calculate time means (TM)
            bTM=squeeze(nanmean(b,3));
            cTM=squeeze(nanmean(c,3));
            ACC(:,:,ilead)=aTM./sqrt(bTM.*cTM);
        end
        lead=1:size(ACC,3);

        % ---------------------------------------------------------- save at netcdf
        ncid=netcdf.create(ncSave,'NC_WRITE');
        %Define the dimensions
        dimidlon = netcdf.defDim(ncid,'lon',length(lon));
        dimidlat = netcdf.defDim(ncid,'lat',length(lat));
        dimidlead = netcdf.defDim(ncid,'lead',length(lead));
        %Define IDs for the dimension variables (pressure,time,varsitude,...)
        lon_ID=netcdf.defVar(ncid,'lon','double',[dimidlon]);
        lat_ID=netcdf.defVar(ncid,'lat','double',[dimidlat]);
        lead_ID=netcdf.defVar(ncid,'lead','double',[dimidlead]);
        ACC_ID = netcdf.defVar(ncid,'ACC','double',[dimidlon dimidlat dimidlead]);
        %We are done defining the NetCdf
        netcdf.endDef(ncid);
        %Then store the dimension variables in
        netcdf.putVar(ncid,lon_ID,lon);
        netcdf.putVar(ncid,lat_ID,lat);
        netcdf.putVar(ncid,lead_ID,lead);
        netcdf.putVar(ncid,ACC_ID,ACC);
        %We're done, close the netcdf
        netcdf.close(ncid)     
    end
end
             
