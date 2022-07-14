% July 13, 2022

clear; clc; close all;

zoneA={'lon>190 & lon<305','lat>15 & lat<75'}; % North America (lon>190 & lon<305,lat>15 & lat<75)
zoneB={'lon>275 & lon<330','lat>-20 & lat<15'}; % South America (lon>275 & lon<330,lat>-20 & lat<15)
zoneC={'lon>345 | lon<60','lat>35 & lat<75'}; % Europe (lon>345 | lon<60,lat>35 & lat<75)
zoneD={'lon>340 | lon<60','lat>-10 & lat<35'}; % Africa (lon>340 | lon<60,lat>-10 & lat<35)
zoneE={'lon>60 & lon<145','lat>10 & lat<55'}; % Asia (lon>60 & lon<145,lat>10 & lat<55)
zoneF={'lon>95 & lon<180','lat>-50 & lat<10'}; % Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
zoneG={'lon>0 & lon<360','lat>-90 & lat<90'};
zoneList={zoneA zoneB zoneC zoneD zoneE zoneF zoneG};
zoneName={'1. North America','2. South America','3. Europe','4. Africa','5. Asia','6. SE Asia/Australia','Global'};

% ------------------------------------------ user specifies
fil='tas_2m_ACC_DJFseason_daily_cesm2cam6v2_NCEPCFS_sg_s2s_data.nc';
lon=ncread(fil,'lon');
lat=ncread(fil,'lat');
acc=ncread(fil,'ACC');
izone=7;
% ------------------------------------------

fil='landsea.nc'; % downloaded from: http://www.ncl.ucar.edu/Applications/Data/#cdf
mask=ncread(fil,'LSMASK');
lonmask=ncread(fil,'lon');
latmask=ncread(fil,'lat');
[x,y]=meshgrid(lonmask,latmask);
[xNew,yNew]=meshgrid(lon,lat); 
mask=interp2(x,y,double(mask)',xNew,yNew,'linear',1)'; 

for itime=1:size(acc,3)
    acc0=squeeze(acc(:,:,itime));
    acc0(mask~=1)=NaN;    % this is trivial, because it is already NaN over the ocean
    cosmask=isnan(acc0);
    cosmat=cosd(repmat(lat(:)',[length(lon) 1]));
    cosmat(cosmask==1)=NaN;
    zone=zoneList{izone};
    ACCzone=acc0(eval(zone{1}),eval(zone{2}));
    cosmatzone=cosmat(eval(zone{1}),eval(zone{2}));      
    ACCzone_cosine(itime)=sum(sum(cosmatzone.*ACCzone,1,'omitnan'),2,'omitnan')...
        /sum(sum(cosmatzone,1,'omitnan'),2,'omitnan');
end

figure
contourf(lon,lat,squeeze(acc(:,:,1))')
% ---- obviously something is wonky

