% May 11, 2022

clear; clc; close all;

% actual/full forecast (2 vars, 4 seasons/plots, 7 zones/subplots in each, 2 styes (actual vs inferred))

% inferred/sum ACC (4 plots, 7 zones/subplots in each)
% atm_gm=ACCgm_save(4,:)-ACCgm_save(1,:); % fullALL - climoATM
% ocn_gm=ACCgm_save(4,:)-ACCgm_save(3,:); % fullALL - climoOCN
% sum_gm=atm_gm+ocn_gm+ACCgm_save(2,:);

% DJF: zones 1 2 3 4 5 6 global
% MAM: zones 1 2 3 4 5 6 global
% JJA: zones 1 2 3 4 5 6 global
% SON: zones 1 2 3 4 5 6 global


% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m';
season='SON';
% ------------------------- SPECIFY ABOVE -------------------------

simList={'cesm2cam6climoATMv2','cesm2cam6climoOCNclimoATMv2',...
    'cesm2cam6climoOCNv2','cesm2cam6v2'};
lineColor=[255 165 0; 34 139 34; 0 0 205; 0 0 0]./255; % sim color
timeAvg='daily';
printName=sprintf('%s_ACC_line_daily_%s_ALLzones',var,season);
titleName=sprintf('%s 2m Temperature ACC',season);

zoneA={'lon>190 & lon<305','lat>15 & lat<75'}; % North America (lon>190 & lon<305,lat>15 & lat<75)
zoneB={'lon>275 & lon<330','lat>-20 & lat<15'}; % South America (lon>275 & lon<330,lat>-20 & lat<15)
zoneC={'lon>345 | lon<60','lat>35 & lat<75'}; % Europe (lon>345 | lon<60,lat>35 & lat<75)
zoneD={'lon>340 | lon<60','lat>-10 & lat<35'}; % Africa (lon>340 | lon<60,lat>-10 & lat<35)
zoneE={'lon>60 & lon<145','lat>10 & lat<55'}; % Asia (lon>60 & lon<145,lat>10 & lat<55)
zoneF={'lon>95 & lon<180','lat>-50 & lat<10'}; % Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
zoneG={'lon>0 & lon<360','lat>-90 & lat<90'};
zoneList={zoneA zoneB zoneC zoneD zoneE zoneF zoneG};
zoneName={'1. North America','2. South America','3. Europe','4. Africa','5. Asia','6. SE Asia/Australia','Global'};
subpos=[0.05 0.6 0.2 0.2; 0.05 0.25 0.2 0.2; ...
        0.29 0.6 0.2 0.2; 0.29 0.25 0.2 0.2; ...
        0.53 0.6 0.2 0.2; 0.53 0.25 0.2 0.2; ...
        0.77 0.6 0.2 0.2];

for izone=1:7
    for isim=1:length(simList)
        simName=simList{isim};
        accFile=sprintf('%s_ACC_%sseason_%s_%s_s2s_data.nc',...
            var,season,timeAvg,simName);
        lon=ncread(accFile,'lon');
        lat=ncread(accFile,'lat');
        acc=ncread(accFile,'ACC');
        clear ACCzone_cosine
        for itime=1:size(acc,3)
            acc0=squeeze(acc(:,:,itime));
            % acc0(mask==0)=NaN;    % this is trivial, because it is already NaN over the ocean
            cosmask=isnan(acc0);
            cosmat=cosd(repmat(lat(:)',[length(lon) 1]));
            cosmat(cosmask==1)=NaN;
            zone=zoneList{izone};
            ACCzone=acc0(eval(zone{1}),eval(zone{2}));
            cosmatzone=cosmat(eval(zone{1}),eval(zone{2}));      
            ACCzone_cosine(itime)=sum(sum(cosmatzone.*ACCzone,1,'omitnan'),2,'omitnan')...
                /sum(sum(cosmatzone,1,'omitnan'),2,'omitnan');
        end
        subplot('position',subpos(izone,:))
        hold on; grid on; box on;
        plot(1:45,ACCzone_cosine,'color',lineColor(isim,:),'linewidth',1.5)
        xlabel('Week');
        title(zoneName{izone});
        axis([0 46 0 1]);
        set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
    end
end

% Fake Plot (to make lengend)
p(1)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2);
p(2)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(3)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2); 
p(4)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(5)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2);
p(6)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(7)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2);
legend(p,'\bfclimoATM','(OCN+LND Predictability)',...
    '\bfclimoOCNclimoATM','(LND Predictability)',...
    '\bfclimoOCN','(ATM+LND Predictability)',...
    '\bffullALL','box','off','position',[.77 .25 .2 .2]);

sgtitle(titleName,'fontweight','bold') 
print(printName,'-r300','-dpng');
