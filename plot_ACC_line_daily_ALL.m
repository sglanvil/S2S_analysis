% May 11, 2022

clear; clc; close all;

% 4 seasons/plots, 7 zones/subplots in each
% 2 variables (tas_2m and pr_sfc)
% --> 4 figures per variable

% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m';
season='DJF';
scenarioName='scenario1';
titleName=sprintf('%s Surface Temperature ACC (%s)',season,scenarioName);
printName=sprintf('/glade/work/sglanvil/CCR/S2S/figures/%s_ACC_line_daily_%s_ALLzones_%s',...
    var,season,scenarioName);
% ------------------------- SPECIFY ABOVE -------------------------

simList={'cesm2cam6climoATMv2','cesm2cam6climoLNDv2','cesm2cam6climoOCNv2',...
    'cesm2cam6v2','cesm2cam6climoOCNclimoATMv2','cesm2cam6climoATMclimoLNDv2'};
lineColor=[255 165 0; 34 139 34; 0 0 205; 0 0 0]./255; % sim color
timeAvg='daily';

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
        % ----------------- ACTUAL -----------------
%         subplot('position',subpos(izone,:))
%         hold on; grid on; box on;
%         plot(1:45,ACCzone_cosine,'color',lineColor(isim,:),'linewidth',1.5)
%         area(1:45,ACCzone_cosine,'edgecolor',lineColor(isim,:),...
%             'facecolor',lineColor(isim,:),'facealpha',0.15','linewidth',1.5)
%         xlabel('Week');
%         title(zoneName{izone});
%         axis([0 46 0 1]);
%         set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
%         set(gca,'ytick',0:0.2:1);
        % ---------------------------------------------
    end
end



% ----------------- INFERRED -----------------
atm=squeeze(ACCsave(:,4,:)-ACCsave(:,1,:)); % standard-climoATM
lnd=squeeze(ACCsave(:,4,:)-ACCsave(:,2,:)); % standard-climoLND
ocn=squeeze(ACCsave(:,4,:)-ACCsave(:,3,:)); % standard-climoOCN
sum=squeeze(atm+lnd+ocn); % atm+ocn+land
standard=squeeze(ACCsave(:,4,:)); % standard
ocnatm=squeeze(ACCsave(:,5,:));
atmlnd=squeeze(ACCsave(:,6,:));
recreated=atm+ocnatm+ocn;
for izone=1:7
    subplot('position',subpos(izone,:))
    hold on; grid on; box on;
    area([14 28],[1 1],'edgecolor','none','facecolor',[128 0 0]/255,...
        'facealpha',0.05);
    area(1:45,sum(izone,:),'edgecolor',lineColor(4,:),'facecolor',lineColor(4,:),...
        'facealpha',0.05,'linewidth',1.5); 
    area(1:45,lnd(izone,:),'edgecolor',lineColor(2,:),'facecolor',lineColor(2,:),...
        'facealpha',0.2,'linewidth',1.5);        
    area(1:45,atm(izone,:),'edgecolor',lineColor(1,:),'facecolor',lineColor(1,:),...
        'facealpha',0.2,'linewidth',1.5);
    area(1:45,ocn(izone,:),'edgecolor',lineColor(3,:),'facecolor',lineColor(3,:),...
        'facealpha',0.2,'linewidth',1.5);    
    plot(1:45,ocnatm(izone,:),'color',lineColor(2,:),'linewidth',2.5,'linestyle',':')
    plot(1:45,atmlnd(izone,:),'color',lineColor(3,:),'linewidth',2.5,'linestyle',':')
    plot(1:45,recreated(izone,:),'color',lineColor(4,:),'linewidth',2.5,'linestyle',':')
    plot(1:45,standard(izone,:),'color',[.5 .5 .5],'linewidth',1.5)
    xlabel('Week');
    title(zoneName{izone});
    axis([1.01 45 -0.1 1]); % do x=1.01 because "area" function plots y=0 at beginning
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
    set(gca,'ytick',0:0.2:1);
end
% ---------------------------------------------


% ----------------- FAKE PLOT (for legend) -----------------
p(1)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2);
p(2)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(3)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2); 
p(4)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(5)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2);
p(6)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(7)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2);
p(8)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);

p(9)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2,'linestyle',':');
p(10)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(11)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2,'linestyle',':');
p(12)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(13)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2,'linestyle',':');
p(14)=plot([1 45],[-100 -100],'color',[1 1 1],'linewidth',2);
p(15)=plot([1 45],[-100 -100],'color',[.5 .5 .5],'linewidth',2);

% ----------------- ACTUAL -----------------
% legend(p,'\bfclimoATM','(OCN+LND Predictability)',...
%     '\bfclimoOCNclimoATM','(LND Predictability)',...
%     '\bfclimoOCN','(ATM+LND Predictability)',...
%     '\bfstandard','box','off','position',[.77 .25 .2 .2]);
% ----------------- INFERRED -----------------
legend(p,'\bfstandard-climoATM','(ATMvar)',...
    '\bfstandard-climoLND','(LNDvar)',...
    '\bfstandard-climoOCN','(OCNvar)',...
    '\bfsum of solid','(ALLvar)',...
    '\bfclimoOCNclimoATM','(LNDclim+LNDvar+...)',... 
    '\bfclimoATMclimoLND','(OCNclim+OCNvar+...)',... 
    '\bfrecreated','(see side text)',...
    '\bfstandard',... 
    'box','off','position',[.77 .18 .2 .2]);

annotation('textbox',[0.02,0.13,0,0],'string','recreated=(standard-climoATM)+(climoOCNclimoATM)+(standard-climoOCN)')
annotation('textbox',[0.02,0.1,0,0],'string','recreated=(ATMvar)+(LNDclim+LNDvar+OCNclim+ATMclim)+(OCNvar)')
annotation('textbox',[0.02,0.07,0,0],'string','recreated=(yellow\_solid)+(green\_dash)+(blue\_solid)')

sgtitle(titleName,'fontweight','bold') 
print(printName,'-r300','-dpng');
