% clear; clc; close all;
% ------------------ SPECIFY ------------------
% varNameIn='tas_2m';
% varNameOut='tas_2m';
% caseName='cesm2cam6climoATMv2';
% scenario='scenario4';
% ---------------------------------------------

fileListing=fopen(sprintf('/glade/work/sglanvil/CCR/S2S/fileListings/%s.S2S.%s.%s',varNameIn,caseName,scenario));
fileClim=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/data/%s_clim_%s.%s_s2s_data.nc',varNameOut,caseName,scenario);
ncSave=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/data/%s_anom_%s.%s_s2s_data.nc',varNameOut,caseName,scenario);

clim=ncread(fileClim,'clim');
climCyclical=cat(4,clim,clim,clim); % make a 3-year loop of clims
climSmooth=movmean(movmean(climCyclical,31,4,'omitnan'),31,4,'omitnan');
% 31 day window to copy Lantao, but maybe it should be 16
clear climCyclical clim
climSmooth=climSmooth(:,:,:,366:366+364); % choose the middle year (smoothed)
dateStrPrevious='01jan1000'; % just a random old date that doesn't exist
blah=0; % set blah to 0 for the very first file date
forecastCounter=0;
tline = fgetl(fileListing);
while ischar(tline)
    disp(tline)
    fil=tline;
    dateStr=extractBetween(fil,convertCharsToStrings(sprintf('%s_',caseName)),"_00z_d01");
    starttime=datetime(dateStr,'InputFormat','ddMMMyyyy');
    doy=day(starttime,'dayofyear');
    if mod(year(starttime),4)==0  && month(starttime)>2
        doy=doy-1;
    end
    var=ncread(fil,varNameIn);  
    if size(var,3)~=46
        disp('error')
        size(var)
        var=NaN(size(ensAvg,1),size(ensAvg,2),size(ensAvg,3));
    end
    if blah==0
        % only do this at the beginning (blah=0)
        lon=ncread(fil,'lon');
        lat=ncread(fil,'lat');
    end
    if strcmp(dateStr{1},dateStrPrevious)==1
        x=x+1;
        ensAvg=(ensAvg*(x-1)+var)/x;
    else
        if blah~=0 && isempty(ensAvg)==0
            % make sure we are past the very first file date (blah~=0)
            % and make sure array actually has data (isempty=0)
            forecastCounter=forecastCounter+1;
            anom(:,:,:,forecastCounter)=ensAvg-...
                squeeze(climSmooth(:,:,:,doyPrevious));
            starttimeBin(forecastCounter)=starttimePrevious;
        end
        ensAvg=var;
        x=1;
    end
    tline = fgetl(fileListing);
    dateStrPrevious=dateStr{1};
    starttimePrevious=starttime;
    doyPrevious=doy;
    blah=blah+1;
end
forecastCounter=forecastCounter+1;
anom(:,:,:,forecastCounter)=ensAvg-...
    squeeze(climSmooth(:,:,:,doyPrevious));
starttimeBin(forecastCounter)=starttimePrevious;
fclose(fileListing);
squeeze(anom(200,100,1,:)) % just check

% ------------------------ save at netcdf ------------------------
lead=1:size(climSmooth,3);
time=datenum(starttimeBin);
date=str2num(datestr(starttimeBin,'yyyymmdd'))';
ncid=netcdf.create(ncSave,'NC_WRITE');
dimidlon = netcdf.defDim(ncid,'lon',length(lon));
dimidlat = netcdf.defDim(ncid,'lat',length(lat));
dimidlead = netcdf.defDim(ncid,'lead',length(lead));
dimidtime = netcdf.defDim(ncid,'time',length(time));
dimiddate = netcdf.defDim(ncid,'date',length(date));
lon_ID=netcdf.defVar(ncid,'lon','float',[dimidlon]);
lat_ID=netcdf.defVar(ncid,'lat','float',[dimidlat]);
lead_ID=netcdf.defVar(ncid,'lead','float',[dimidlead]);
time_ID=netcdf.defVar(ncid,'time','float',[dimidtime]);
date_ID=netcdf.defVar(ncid,'date','int',[dimiddate]);
anom_ID=netcdf.defVar(ncid,'anom','float',[dimidlon dimidlat dimidlead dimidtime]);
netcdf.endDef(ncid);
netcdf.putVar(ncid,lat_ID,lat);
netcdf.putVar(ncid,lon_ID,lon);
netcdf.putVar(ncid,lead_ID,lead);
netcdf.putVar(ncid,time_ID,time);
netcdf.putVar(ncid,anom_ID,anom);
netcdf.putVar(ncid,date_ID,date);
netcdf.close(ncid)

