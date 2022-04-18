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
end

subpos=[0.12 0.55 0.35 0.35; 0.58 0.55 0.35 0.35; ...
    0.12 0.1 0.35 0.35; 0.58 0.1 0.35 0.35];
lineColor=[255 165 0; 34 139 34; 0 0 205; 0 0 0]./255;
figure
subplot('position',subpos(1,:));
    hold on; grid on; box on;
    plot(1:45,ACCgm_save(1,:),'color',lineColor(1,:),'linewidth',2);
    plot(1:45,ACCgm_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCgm_save(2,:),'color',lineColor(2,:),'linewidth',2);
    plot(1:45,ACCgm_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCgm_save(3,:),'color',lineColor(3,:),'linewidth',2);
    plot(1:45,ACCgm_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCgm_save(4,:),'color',lineColor(4,:),'linewidth',2);
    title('DJF Global Land');
    ylabel('ACC','fontweight','bold');
    axis([0 46 0 0.8]);
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
        
subplot('position',subpos(2,:));
    hold on; grid on; box on;
    plot(1:45,ACCnam_save(1,:),'color',lineColor(1,:),'linewidth',2);
    plot(1:45,ACCnam_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCnam_save(2,:),'color',lineColor(2,:),'linewidth',2);
    plot(1:45,ACCnam_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCnam_save(3,:),'color',lineColor(3,:),'linewidth',2);
    plot(1:45,ACCnam_save(1,:)*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCnam_save(4,:),'color',lineColor(4,:),'linewidth',2);
    title('DJF North America Land');
    axis([0 46 0 0.8]);
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
    
legend('\bfclimoATM','(OCN+LND Predictability)','\bfclimoOCNclimoATM','(LND Predictability)',...
    '\bfclimoOCN','(ATM+LND Predictability)','\bffullALL','box','off','location','best','fontsize',8);

atm_gm=ACCgm_save(4,:)-ACCgm_save(1,:); % fullALL - climoATM
ocnatm_gm=ACCgm_save(4,:)-ACCgm_save(2,:); % fullALL - climoOCNclimoATM
ocn_gm=ACCgm_save(4,:)-ACCgm_save(3,:); % fullALL - climoOCN
sum_gm=atm_gm+ocn_gm+ACCgm_save(2,:);

atm_nam=ACCnam_save(4,:)-ACCnam_save(1,:); % fullALL - climoATM
ocnatm_nam=ACCnam_save(4,:)-ACCnam_save(2,:); % fullALL - climoOCNclimoATM
ocn_nam=ACCnam_save(4,:)-ACCnam_save(3,:); % fullALL - climoOCN
sum_nam=atm_nam+ocn_nam+ACCnam_save(2,:);

subplot('position',subpos(3,:));
    hold on; grid on; box on;
    plot(1:45,atm_gm,'color',lineColor(1,:),'linewidth',2);
    plot(1:45,ACCgm_save(2,:),'color',lineColor(2,:),'linewidth',2);
    plot(1:45,ocn_gm,'color',lineColor(3,:),'linewidth',2);
    plot(1:45,sum_gm,'color',lineColor(4,:),'linewidth',2);
    ylabel('ACC','fontweight','bold');
    xlabel('Week','fontweight','bold');
    axis([0 46 0 0.8]);
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
        
subplot('position',subpos(4,:));
    hold on; grid on; box on;
    plot(1:45,atm_nam,'color',lineColor(1,:),'linewidth',2);
    plot(1:45,atm_nam*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ACCnam_save(2,:),'color',lineColor(2,:),'linewidth',2);
    plot(1:45,atm_nam*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,ocn_nam,'color',lineColor(3,:),'linewidth',2);
    plot(1:45,atm_nam*-200,'color',[1 1 1]); % INVISIBLE LINE
    plot(1:45,sum_nam,'color',lineColor(4,:),'linewidth',2);
    xlabel('Week','fontweight','bold');
    axis([0 46 0 0.8]);
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
        
% legend({['fullALL-climoATM' newline 'ATM'],['climoOCNclimoATM' newline 'LND'],...
%     ['fullALL-climoOCN' newline 'OCN'],'sum'},'box','off');
legend('\bffullALL-climoATM','(ATM Predictability)','\bfclimoOCNclimoATM','(LND Predictability)',...
    '\bffullALL-climoOCN','(OCN Predictability)','\bfsum','box','off','location','best','fontsize',8);

print(printName,'-r250','-dpng');

