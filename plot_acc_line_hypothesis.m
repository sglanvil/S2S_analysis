% December 17, 2022
clear; clc; close all;

printName='hypothesis_ACC_line_daily_CESM';

x=0:12;
xN=linspace(0,12,46);
yOCN=[0.0 0.1 0.2 0.4 0.6 0.9 1.2 1.8 2.5 3.1 3.8 4.2 4.5]/15/1.8;
yLND=[0.0 3.9 5.6 5.9 5.6 5.1 4.6 4.0 3.5 3.0 2.6 2.3 2.1]/15/1.8;
yATM=[15 11.6 7.4 4.5 2.9 1.9 1.4 1.1 1.0 0.9 0.8 0.7 0.6]/15/1.8;
yOCN=movmean(interp1(x,yOCN,xN),2);
yLND=movmean(interp1(x,yLND,xN),2);
yATM=movmean(interp1(x,yATM,xN),2);

lineColor=[204 187 68; 34 136 51; 102 204 238; 0 0 0]./255;

subplot('position',[.06 .5 .4 .4])
hold on; grid on; box on;
area([14 28],[2 2],'edgecolor','none','facecolor',[.5 .5 .5],...
    'facealpha',0.1);
area([14 28],[-1 -1],'edgecolor','none','facecolor',[.5 .5 .5],...
    'facealpha',0.1);
area(0:45,yLND,'edgecolor','none','facecolor',lineColor(2,:),...
    'facealpha',0.2,'linewidth',2.5); 
plot(0:45,yLND,'color',lineColor(2,:),'linewidth',2.5);
area(0:45,yATM,'edgecolor','none','facecolor',lineColor(1,:),...
    'facealpha',0.2,'linewidth',2.5);
plot(0:45,yATM,'color',lineColor(1,:),'linewidth',2.5);
area(0:45,yOCN,'edgecolor','none','facecolor',lineColor(3,:),...
    'facealpha',0.2,'linewidth',2.5);   
plot(0:45,yOCN,'color',lineColor(3,:),'linewidth',2.5);
% text(7,0.8,'atmosphere','color',lineColor(1,:),'fontsize',13,'fontweight','bold');
% text(20,0.4,'land','color',lineColor(2,:),'fontsize',13,'fontweight','bold');
% text(36,0.34,'ocean','color',lineColor(3,:),'fontsize',13,'fontweight','bold');

p(1)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2.5); 
p(2)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5); 
p(3)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5);
lgd=legend(p,'atmo','land','ocean','fontsize',13);

xlabel('\bfWeek');
ylabel('\bfPredictability');
title('(a) Hypothesis');
set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
set(gca,'ytick',0:0.1:1,'yticklabel',[]);
axis([0 45 -0.02 0.6]); % do x=1.01 because "area" function plots y=0 at beginning
set(gca,'fontsize',13);

% print(printName,'-r300','-dpng');

% -------------------------- Added March 3, 2023 --------------------------

lon=0:359;
lat=-90:90;
fil='/Users/sglanvil/Documents/S2S_analysis/landsea.nc'; % downloaded from: http://www.ncl.ucar.edu/Applications/Data/#cdf
mask0=ncread(fil,'LSMASK');
lonmask=ncread(fil,'lon');
latmask=ncread(fil,'lat');
[x,y]=meshgrid(lonmask,latmask);
[xNew,yNew]=meshgrid(lon,lat); 
mask=interp2(x,y,double(mask0)',xNew,yNew,'linear',1)'; 

zoneA={'lon>0 & lon<360','lat>30 & lat<60'}; 
zoneList={zoneA};

% Yellow, Green, Blue, Black, Red
lineColor=[204 187 68; 34 136 51; 102 204 238; 0 0 0; 238 102 119]./255;

% climoALLFIX --> climoALL
% climoOCNFIXclimoLND --> climoOCNclimoLND (full atmosphere)
% climoALL --> climoATMclimoLND (full ocean)
simList={'cesm2cam6climoATMv2','cesm2cam6climoLNDv2','cesm2cam6climoOCNv2',...
    'cesm2cam6v2','cesm2cam6climoOCNclimoATMv2','cesm2cam6climoALLv2',...
    'cesm2cam6climoOCNFIXclimoLNDv2','cesm2cam6climoALLFIXv2' };

var='tas_2m'; varLong='2m Temperature'; obsName='ERA5'; timeFreq='daily';
composite='ALL'; % [ALL,DJF,JJA,EL,LA]
scenarioName='scenario1'; % [scenario1] only
titleName=sprintf('%s %s ACC (%s)',composite,varLong,obsName);
% ------------------------- SPECIFY ABOVE -------------------------

izone=1;
for isim=1:length(simList)
    simName=simList{isim};
    addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/
    sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
    fileString1=sprintf('%s_ACC_%scomposite_%s_%s.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,simName,obsName);
    accFile=dir(fullfile(sourceDir,fileString1)).name;     
    lon=ncread(accFile,'lon');
    lat=ncread(accFile,'lat');
    acc=ncread(accFile,'ACC');
    clear ACCzone_cosine
    for itime=1:size(acc,3)
        zone=zoneList{izone};
        acc0=squeeze(acc(:,:,itime));
        cosmat=cosd(repmat(lat(:)',[length(lon) 1]));
        cosmatzone=cosmat(eval(zone{1}),eval(zone{2}));      

        maskzone=mask(eval(zone{1}),eval(zone{2}));
        coslat_vector=cosmatzone(maskzone>0);
        ACCzone=acc0(eval(zone{1}),eval(zone{2}));
        acc_vector=ACCzone(maskzone>0);

        if isim==4 % bootstrap resampling with replacement, 30 samples
            for boot=1:30
                bootsample=randi(length(coslat_vector),round(length(coslat_vector)/10),1);
                coslat_boot=coslat_vector(bootsample);
                acc_boot=acc_vector(bootsample);
                acc_sample(boot)=sum(coslat_boot.*acc_boot)/sum(coslat_boot);
            end
            se=std(acc_sample); % standard error
            t_crit=tinv(0.975,30);
            ci=mean(acc_sample)+[t_crit*se -t_crit*se];
            se_save(itime)=se;
        end

        acc0(mask==0)=NaN; % NaN out the ocean
        cosmask=isnan(acc0);
        cosmat(cosmask==1)=NaN;
        cosmatzone=cosmat(eval(zone{1}),eval(zone{2}));      
        ACCzone=acc0(eval(zone{1}),eval(zone{2}));

        ACCzone_cosine(itime)=sum(sum(cosmatzone.*ACCzone,1,'omitnan'),2,'omitnan')...
            /sum(sum(cosmatzone,1,'omitnan'),2,'omitnan');
    end
    ACCsave(isim,:)=ACCzone_cosine;
end

% ----------------- first method of attaining variability -----------------
standard=squeeze(ACCsave(4,:)); % standard
climoATM=squeeze(ACCsave(1,:));
climoLND=squeeze(ACCsave(2,:));
climoOCN=squeeze(ACCsave(3,:));
atmVar=squeeze(ACCsave(4,:)-ACCsave(1,:)); % standard-climoATM
lndVar=squeeze(ACCsave(4,:)-ACCsave(2,:)); % standard-climoLND
ocnVar=squeeze(ACCsave(4,:)-ACCsave(3,:)); % standard-climoOCN
lndFULL=squeeze(ACCsave(5,:));
ocnFULL=squeeze(ACCsave(6,:));
atmFULL=squeeze(ACCsave(7,:));
allClim=squeeze(ACCsave(8,:));
% ----------------- second method of attaining variability -----------------
atmVar2=atmFULL-allClim;
lndVar2=lndFULL-allClim;
ocnVar2=ocnFULL-allClim;
feedbackAL=lndVar2-lndVar;
feedbackAO=ocnVar2-ocnVar;
total=allClim+atmVar+lndVar+ocnVar+feedbackAL+feedbackAO;
    

subplot('position',[.56 .5 .4 .4])
hold on; grid on; box on;
area([14 28],[1 1],'edgecolor','none','facecolor',[.5 .5 .5],...
    'facealpha',0.1);
area([14 28],[-1 -1],'edgecolor','none','facecolor',[.5 .5 .5],...
    'facealpha',0.1);
area(0:45,lndVar,'edgecolor','none','facecolor',lineColor(2,:),...
    'facealpha',0.2,'linewidth',2.5); 
plot(0:45,lndVar,'color',lineColor(2,:),'linewidth',2.5);
area(0:45,atmVar,'edgecolor','none','facecolor',lineColor(1,:),...
    'facealpha',0.2,'linewidth',2.5);
plot(0:45,atmVar,'color',lineColor(1,:),'linewidth',2.5);
area(0:45,ocnVar,'edgecolor','none','facecolor',lineColor(3,:),...
    'facealpha',0.2,'linewidth',2.5);   
plot(0:45,ocnVar,'color',lineColor(3,:),'linewidth',2.5);
area(0:45,feedbackAL,'edgecolor','none','facecolor',lineColor(2,:),...
    'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
plot(0:45,feedbackAL,'color',lineColor(2,:),'linewidth',2.5,'linestyle',':');
area(0:45,feedbackAO,'edgecolor','none','facecolor',lineColor(3,:),...
    'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
plot(0:45,feedbackAO,'color',lineColor(3,:),'linewidth',2.5,'linestyle',':');

p(1)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2.5); 
p(2)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5); 
p(3)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5);
p(4)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5,'linestyle',':');
p(5)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5,'linestyle',':');
lgd=legend(p,'atmo','land','ocean','atmo-land','atmo-ocean','fontsize',13);

set(gca,'ytick',0:0.1:1,'yticklabel',0:0.1:1);
set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
ylabel('\bfACC');
xlabel('\bfWeek');
title('(b) CESM');

axis([0 45 -0.02 0.6]); % do x=1.01 because "area" function plots y=0 at beginning
set(gca,'fontsize',13);

print(printName,'-r300','-dpng');





