% April 14, 2022
clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
varName='tas_2m';

simList={'cesm2cam6climoATMv2','cesm2cam6climoOCNclimoATMv2',...
    'cesm2cam6climoOCNv2','cesm2cam6v2'};

season='DJF';
timeAvg='daily';
printName='/glade/work/sglanvil/CCR/S2S/figures/tas_2m_ACC_line_DJF_daily';
% ------------------------- SPECIFY ABOVE -------------------------

subpos=[0.12 0.55 0.35 0.35; 0.58 0.55 0.35 0.35; ...
    0.12 0.1 0.35 0.35; 0.58 0.1 0.35 0.35];

% yellow, purple, blue, black
lineColor=[255 165 0; 148 0 211; 0 0 205; 0 0 0]./255;
figure
for isim=1:length(simList)
    simName=simList{isim};
    accFile=sprintf('/glade/work/sglanvil/CCR/S2S/data/%s_ACC_%sseason_%s_%s_s2s_data.nc',...
        varName,season,timeAvg,simName);
    lon=ncread(accFile,'lon');
    lat=ncread(accFile,'lat');
    acc=ncread(accFile,'ACC');
    clear ACCgm_cosine ACCnam_cosine
    for itime=1:size(acc,3)
        % ------------ new cosine method -----------
        acc0=squeeze(acc(:,:,itime));
        % acc0(mask==0)=NaN;    % this is trivial, because it is already NaN over the ocean
        cosmask=isnan(acc0);
        cosmat=cosd(repmat(lat(:)',[length(lon) 1]));
        cosmat(cosmask==1)=NaN;
        ACCgm_cosine(itime)=sum(sum(cosmat.*acc0,1,'omitnan'),2,'omitnan')...
            /sum(sum(cosmat,1,'omitnan'),2,'omitnan');
        ACCnam=acc0(lon>190 & lon<305,lat>15 & lat<75);
        cosmatnam=cosmat(lon>190 & lon<305,lat>15 & lat<75);
        ACCnam_cosine(itime)=sum(sum(cosmatnam.*ACCnam,1,'omitnan'),2,'omitnan')...
            /sum(sum(cosmatnam,1,'omitnan'),2,'omitnan');
    end
    ACCgm_save(isim,:)=ACCgm_cosine;
    ACCnam_save(isim,:)=ACCnam_cosine;
    subplot('position',subpos(1,:));
        hold on; grid on; box on;
        plot(1:45,ACCgm_cosine,'color',lineColor(isim,:),'linewidth',2);
        title('DJF Global Land');
        ylabel('ACC','fontweight','bold');
        xlabel('time (days)','fontweight','bold');
        axis([0 46 0 0.8]);
    subplot('position',subpos(2,:));
        hold on; grid on; box on;
        plot(1:45,ACCnam_cosine,'color',lineColor(isim,:),'linewidth',2);
        title('DJF North America Land');
        xlabel('time (days)','fontweight','bold');
        axis([0 46 0 0.8]);
end

atm_gm=ACCgm_save(4,:)-ACCgm_save(1,:); % trALL - climoATM
ocn_gm=ACCgm_save(4,:)-ACCgm_save(3,:); % trALL - climoOCN
atm_nam=ACCnam_save(4,:)-ACCnam_save(1,:); % trALL - climoATM
ocn_nam=ACCnam_save(4,:)-ACCnam_save(3,:); % trALL - climoOCN

subplot('position',subpos(1,:));
    plot(1:45,atm_gm,'color',lineColor(1,:),'linewidth',2,'linestyle','--');
    plot(1:45,ocn_gm,'color',lineColor(3,:),'linewidth',2,'linestyle','--');

subplot('position',subpos(2,:));
    plot(1:45,atm_nam,'color',lineColor(1,:),'linewidth',2,'linestyle','--');
    plot(1:45,ocn_nam,'color',lineColor(3,:),'linewidth',2,'linestyle','--');
    
    
legend('climoATM','climoOCNclimoATM','climoOCN','trALL','trALL-climoATM','trALL-climoOCN');
print(printName,'-r300','-dpng');

