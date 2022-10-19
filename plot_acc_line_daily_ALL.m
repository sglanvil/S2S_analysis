% May 11, 2022

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m';
season='DJF';
scenarioName='scenario1';
varOrFullOption='var2';
titleName=sprintf('%s Surface Temperature ACC',season);
printName=sprintf('/glade/work/sglanvil/CCR/S2S/figures/%s_ACC_line_daily_%s_ALLzones_%s',...
    var,season,varOrFullOption);
% ------------------------- SPECIFY ABOVE -------------------------

% climoALLFIX --> climoALL
% climoOCNFIXclimoLND --> climoOCNclimoLND (yellow dashed, has full atmosphere)
% climoOCNclimoLND --> climoLND (can be deleted!)
% climoALL --> climoATMclimoLND (blue dashed, has full ocean)

simList={'cesm2cam6climoATMv2','cesm2cam6climoLNDv2','cesm2cam6climoOCNv2',...
    'cesm2cam6v2','cesm2cam6climoOCNclimoATMv2','cesm2cam6climoALLv2',...
    'cesm2cam6climoOCNFIXclimoLNDv2','cesm2cam6climoALLFIXv2' };
lineColor=[255 165 0; 34 139 34; 0 0 205; 0 0 0; 255 0 0]./255; % sim color
timeAvg='daily';

zoneA={'lon>190 & lon<305','lat>15 & lat<75'}; % North America (lon>190 & lon<305,lat>15 & lat<75)
zoneB={'lon>275 & lon<330','lat>-20 & lat<15'}; % South America (lon>275 & lon<330,lat>-20 & lat<15)
zoneC={'lon>345 | lon<60','lat>35 & lat<75'}; % Europe (lon>345 | lon<60,lat>35 & lat<75)
zoneD={'lon>340 | lon<60','lat>-10 & lat<35'}; % Africa (lon>340 | lon<60,lat>-10 & lat<35)
zoneE={'lon>60 & lon<145','lat>10 & lat<55'}; % Asia (lon>60 & lon<145,lat>10 & lat<55)
zoneF={'lon>95 & lon<180','lat>-50 & lat<10'}; % Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
zoneG={'lon>0 & lon<360','lat>-90 & lat<90'};
zoneList={zoneA zoneB zoneC zoneD zoneE zoneF zoneG};
zoneName={'North America','South America','Europe','Africa','Asia','SE Asia/Australia','Global'};
subpos=[0.05 0.6 0.2 0.2; 0.05 0.25 0.2 0.2; ...
        0.29 0.6 0.2 0.2; 0.29 0.25 0.2 0.2; ...
        0.53 0.6 0.2 0.2; 0.53 0.25 0.2 0.2; ...
        0.77 0.6 0.2 0.2];

for izone=1:7
    for isim=1:length(simList)
        simName=simList{isim};
        accFile=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/data/%s_ACC_%sseason_%s_%s.%s_s2s_data.nc',...
            var,season,timeAvg,simName,scenarioName);
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
        ACCsave(izone,isim,:)=ACCzone_cosine;
    end
end



% ----------------- INFERRED -----------------

standard=squeeze(ACCsave(:,4,:)); % standard

% first method of attaining variability
atmVar=squeeze(ACCsave(:,4,:)-ACCsave(:,1,:)); % standard-climoATM
lndVar=squeeze(ACCsave(:,4,:)-ACCsave(:,2,:)); % standard-climoLND
ocnVar=squeeze(ACCsave(:,4,:)-ACCsave(:,3,:)); % standard-climoOCN
sumVar=squeeze(atmVar+lndVar+ocnVar); % atm+ocn+land

lndFull=squeeze(ACCsave(:,5,:));
ocnFull=squeeze(ACCsave(:,6,:));
atmFull=squeeze(ACCsave(:,7,:));

allClim=squeeze(ACCsave(:,8,:));

% second method of attaining variability
atmVar2=atmFull-allClim;
lndVar2=lndFull-allClim;
ocnVar2=ocnFull-allClim;
sumVar2=squeeze(atmVar2+lndVar2+ocnVar2); % atm2+ocn2+land2


for izone=1:7
    subplot('position',subpos(izone,:))
    hold on; grid on; box on;
    
    area([14 28],[1 1],'edgecolor','none','facecolor',[0 0 128]/255,...
        'facealpha',0.05);
    area([14 28],[-1 -1],'edgecolor','none','facecolor',[0 0 128]/255,...
        'facealpha',0.05);
    
    area(1:45,sumVar(izone,:),'edgecolor',lineColor(4,:),'facecolor',lineColor(4,:),...
        'facealpha',0.05,'linewidth',1.5); 
    area(1:45,lndVar(izone,:),'edgecolor',lineColor(2,:),'facecolor',lineColor(2,:),...
        'facealpha',0.2,'linewidth',1.5);        
    area(1:45,atmVar(izone,:),'edgecolor',lineColor(1,:),'facecolor',lineColor(1,:),...
        'facealpha',0.2,'linewidth',1.5);
    area(1:45,ocnVar(izone,:),'edgecolor',lineColor(3,:),'facecolor',lineColor(3,:),...
        'facealpha',0.2,'linewidth',1.5);    
    
    area(1:45,lndVar2(izone,:),'edgecolor',lineColor(2,:),'facecolor',lineColor(2,:),...
        'facealpha',0.2,'linewidth',2,'linestyle',':');        
    area(1:45,atmVar2(izone,:),'edgecolor',lineColor(1,:),'facecolor',lineColor(1,:),...
        'facealpha',0.2,'linewidth',2,'linestyle',':');     
    area(1:45,ocnVar2(izone,:),'edgecolor',lineColor(3,:),'facecolor',lineColor(3,:),...
        'facealpha',0.2,'linewidth',2,'linestyle',':');    
    
%     area(1:45,allClim(izone,:),'edgecolor',lineColor(5,:),'facecolor',lineColor(5,:),...
%         'facealpha',0.2,'linewidth',1.5);    
    plot(1:45,standard(izone,:),'color',[.5 .5 .5],'linewidth',2)

    xlabel('Week');
    title(zoneName{izone});
    axis([1.01 45 -0.1 1]); % do x=1.01 because "area" function plots y=0 at beginning
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
    set(gca,'ytick',0:0.2:1);
end
% ---------------------------------------------


% ----------------- FAKE PLOT (for legend) -----------------
p(1)=plot([1 45],[-100 -100],'color',[.5 .5 .5],'linewidth',2);
p(2)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2); 
p(3)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(4)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2); 
p(5)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(6)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2);
p(7)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(8)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2);
p(9)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
% p(8)=plot([1 45],[-100 -100],'color',lineColor(5,:),'linewidth',2);
% p(9)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);

legend(p,'\bfstandard',...
    '\bfatmos variability','standard-climoATM',...
    '\bfland variability','standard-climoLND',...
    '\bfocean variability','standard-climoOCN',...
    '\bfvariability only','sum of variability',...
    'box','off','position',[.77 .20 .2 .2]);

annotation('textbox',[.04 .1 .5 .1],'string','\bfdashed = variability from another method',...
    'edgecolor','none','verticalalignment','bottom');
annotation('textbox',[.04 .05 .5 .1],'string','\bfdashed = dualClimoRun - climoALLRun',...
    'edgecolor','none','verticalalignment','bottom');

% legend(p,'\bfstandard',...
%     '\bfatmos full','climoOCNclimoLND',...
%     '\bfland full','climoOCNclimoATM',...
%     '\bfocean full','climoATMclimoLND',...
%     '\bfclimatology only','climoALL',...
%     'box','off','position',[.77 .20 .2 .2]);

sgtitle(titleName,'fontweight','bold') 
print(printName,'-r300','-dpng');
