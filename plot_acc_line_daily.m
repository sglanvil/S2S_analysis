% April 14, 2022
clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
varName='tas_2m';

simList={'cesm2cam6climoATMv2','cesm2cam6climoOCNclimoATMv2',...
    'cesm2cam6climoOCNv2','cesm2cam6v2'};

season='DJF';
timeAvg='daily';
% ------------------------- SPECIFY ABOVE -------------------------

for isim=1:length(simList)
    simName=simList{isim};
    accFile=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_%sseason_%s_%s_s2s_data.nc',...
        varName,season,timeAvg,simName);
    lon=ncread(accFile,'lon');
    lat=ncread(accFile,'lat');
    acc=ncread(accFile,'ACC');
    
    for itime=1:size(acc,3)
        % ------------ new cosine method -----------
        acc0=squeeze(acc(:,:,itime));
%         acc0(mask==0)=NaN;    % this is trivial, because it is already NaN over the ocean
        cosmask=isnan(acc0);
        cosmat=cosd(repmat(lat(:)',[length(lon) 1]));
        cosmat(cosmask==1)=NaN;
        ACCgm_cosine=sum(sum(cosmat.*acc0,1,'omitnan'),2,'omitnan')...
            /sum(sum(cosmat,1,'omitnan'),2,'omitnan');
        ACCnam=acc0(lon>190 & lon<305,lat>15 & lat<75);
        cosmatnam=cosmat(lon>190 & lon<305,lat>15 & lat<75);
        ACCnam_cosine=sum(sum(cosmatnam.*ACCnam,1,'omitnan'),2,'omitnan')...
            /sum(sum(cosmatnam,1,'omitnan'),2,'omitnan');
    end
end

