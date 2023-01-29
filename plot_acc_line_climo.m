% December 2, 2022

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
% var='tas_2m'; varLong='2m Temperature'; obsName='ERA5';
var='pr_sfc'; varLong='Surface Precipitation'; obsName='GPCP';
composite='LA'; % [ALL,DJF,JJA,EL,LA]
timeFreq='dailySmooth'; % [daily,dailySmooth]
scenarioName='scenario1'; % [scenario1] only
titleName=sprintf('%s %s ACC (%s)',composite,varLong,obsName);
printName=sprintf('%s_ACC_line_%scomposite_%s_zoomIn_figure',var,composite,obsName);
% ------------------------- SPECIFY ABOVE -------------------------

lon=0:359;
lat=-90:90;
fil='/Users/sglanvil/Documents/S2S_analysis/landsea.nc'; % downloaded from: http://www.ncl.ucar.edu/Applications/Data/#cdf
mask0=ncread(fil,'LSMASK');
lonmask=ncread(fil,'lon');
latmask=ncread(fil,'lat');
[x,y]=meshgrid(lonmask,latmask);
[xNew,yNew]=meshgrid(lon,lat); 
mask=interp2(x,y,double(mask0)',xNew,yNew,'linear',1)'; 

% climoALLFIX --> climoALL
% climoOCNFIXclimoLND --> climoOCNclimoLND (full atmosphere)
% climoALL --> climoATMclimoLND (full ocean)
simList={'cesm2cam6climoATMv2','cesm2cam6climoLNDv2','cesm2cam6climoOCNv2',...
    'cesm2cam6v2','cesm2cam6climoOCNclimoATMv2','cesm2cam6climoALLv2',...
    'cesm2cam6climoOCNFIXclimoLNDv2','cesm2cam6climoALLFIXv2' };
lineColor=[204 187 68; 34 136 51; 102 204 238; 0 0 0]./255;

zoneA={'lon>190 & lon<305','lat>15 & lat<75'}; % North America (lon>190 & lon<305,lat>15 & lat<75)
zoneB={'lon>275 & lon<330','lat>-20 & lat<15'}; % South America (lon>275 & lon<330,lat>-20 & lat<15)
zoneC={'lon>345 | lon<60','lat>35 & lat<75'}; % Europe (lon>345 | lon<60,lat>35 & lat<75)
zoneD={'lon>340 | lon<60','lat>-10 & lat<35'}; % Africa (lon>340 | lon<60,lat>-10 & lat<35)
zoneE={'lon>60 & lon<145','lat>10 & lat<55'}; % Asia (lon>60 & lon<145,lat>10 & lat<55)
zoneF={'lon>95 & lon<180','lat>-50 & lat<10'}; % Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
zoneG={'lon>0 & lon<360','lat>-90 & lat<90'};
zoneList={zoneA zoneB zoneC zoneD zoneE zoneF zoneG};
zoneName={'North America','South America','Europe',...
    'Africa','Asia','SE Asia/Australia','Global'};
subpos=[0.05 0.65 0.2 0.2; 0.05 0.3 0.2 0.2; ...
        0.29 0.65 0.2 0.2; 0.29 0.3 0.2 0.2; ...
        0.53 0.65 0.2 0.2; 0.53 0.3 0.2 0.2; ...
        0.77 0.65 0.2 0.2];
    

for izone=1:7
    for isim=1:length(simList)
        simName=simList{isim};
        
        addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/
        sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
        fileString1=sprintf('%s_ACC_%scomposite_%s_%s.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,simName,obsName);
        accFile=dir(fullfile(sourceDir,fileString1)).name;     

%         accFile=sprintf('/Users/sglanvil/Documents/S2S_climo_experiments/ACC_precip/%s_ACC_%s_%sseason_%s_%s.%s_s2s_data.nc',...
%             var,obsName,composite,timeFreq,simName,scenarioName);

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
                se_save(izone,itime)=se;
            end

            acc0(mask==0)=NaN; % NaN out the ocean
            cosmask=isnan(acc0);
            cosmat(cosmask==1)=NaN;
            cosmatzone=cosmat(eval(zone{1}),eval(zone{2}));      
            ACCzone=acc0(eval(zone{1}),eval(zone{2}));

            ACCzone_cosine(itime)=sum(sum(cosmatzone.*ACCzone,1,'omitnan'),2,'omitnan')...
                /sum(sum(cosmatzone,1,'omitnan'),2,'omitnan');
        end
        ACCsave(izone,isim,:)=ACCzone_cosine;
    end
end




% ----------------- first method of attaining variability -----------------
standard=squeeze(ACCsave(:,4,:)); % standard
climoATM=squeeze(ACCsave(:,1,:));
climoLND=squeeze(ACCsave(:,2,:));
climoOCN=squeeze(ACCsave(:,3,:));
atmVar=squeeze(ACCsave(:,4,:)-ACCsave(:,1,:)); % standard-climoATM
lndVar=squeeze(ACCsave(:,4,:)-ACCsave(:,2,:)); % standard-climoLND
ocnVar=squeeze(ACCsave(:,4,:)-ACCsave(:,3,:)); % standard-climoOCN
sumVar=squeeze(atmVar+lndVar+ocnVar); % atm+ocn+land
lndFULL=squeeze(ACCsave(:,5,:));
ocnFULL=squeeze(ACCsave(:,6,:));
atmFULL=squeeze(ACCsave(:,7,:));
allClim=squeeze(ACCsave(:,8,:));
% ----------------- second method of attaining variability -----------------
atmVar2=atmFULL-allClim;
lndVar2=lndFULL-allClim;
ocnVar2=ocnFULL-allClim;
sumVar2=squeeze(atmVar2+lndVar2+ocnVar2); % atm2+ocn2+land2

varAL=lndVar2-lndVar;
varAO=ocnVar2-ocnVar;
xxx=atmVar+varAL+varAO+lndVar+ocnVar+allClim;

if strcmp(var,'pr_sfc')==1
    for izone=1:7
        for itime=1:46
            if isinf(atmVar(izone,itime)) || isnan(atmVar(izone,itime))
                atmVar(izone,itime)=standard(izone,itime);
            end
            if isinf(atmVar2(izone,itime)) || isnan(atmVar2(izone,itime))
                atmVar2(izone,itime)=standard(izone,itime);
            end
        end
    end
end

figure
for izone=1:7
    subplot('position',subpos(izone,:))
    hold on; grid on; box on;
    area([14 28],[1 1],'edgecolor','none','facecolor',[120 120 120]/255,...
        'facealpha',0.1);
    area([14 28],[-1 -1],'edgecolor','none','facecolor',[120 120 120]/255,...
        'facealpha',0.1);

    plot(1:46,standard(izone,:),'color',lineColor(4,:),'linewidth',2.5)

    area(1:46,lndVar(izone,:),'edgecolor','none','facecolor',lineColor(2,:),...
        'facealpha',0.2,'linewidth',2.5); 
    plot(1:46,lndVar(izone,:),'color',lineColor(2,:),'linewidth',2.5);
    area(1:46,atmVar(izone,:),'edgecolor','none','facecolor',lineColor(1,:),...
        'facealpha',0.2,'linewidth',2.5);
    plot(1:46,atmVar(izone,:),'color',lineColor(1,:),'linewidth',2.5);
    area(1:46,ocnVar(izone,:),'edgecolor','none','facecolor',lineColor(3,:),...
        'facealpha',0.2,'linewidth',2.5);   
    plot(1:46,ocnVar(izone,:),'color',lineColor(3,:),'linewidth',2.5);
    
    area(1:46,lndVar2(izone,:),'edgecolor','none','facecolor',lineColor(2,:),...
        'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
    plot(1:46,lndVar2(izone,:),'color',lineColor(2,:),'linewidth',2.5,'linestyle',':');
    area(1:46,atmVar2(izone,:),'edgecolor','none','facecolor',lineColor(1,:),...
        'facealpha',0.2,'linewidth',2.5,'linestyle',':');     
    plot(1:46,atmVar2(izone,:),'color',lineColor(1,:),'linewidth',2.5,'linestyle',':');
    area(1:46,ocnVar2(izone,:),'edgecolor','none','facecolor',lineColor(3,:),...
        'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
    plot(1:46,ocnVar2(izone,:),'color',lineColor(3,:),'linewidth',2.5,'linestyle',':');

%     plot(1:46,t_crit*se_save(izone,:),'r','linewidth',2)
%     plot(1:46,-t_crit*se_save(izone,:),'r','linewidth',2)

    time=1:46;
    U6010maxLine=t_crit*se_save(izone,:)';
    U6010minLine=-t_crit*se_save(izone,:)';
    fill([time fliplr(time)],[U6010minLine' fliplr(U6010maxLine')],...
        [120 120 120]/255,'facealpha',0.8,'linestyle','none');

%     plot(1:46,varAL(izone,:),'color',lineColor(2,:),'linewidth',2.5,'linestyle','--');
%     plot(1:46,varAO(izone,:),'color',lineColor(3,:),'linewidth',2.5,'linestyle','--');
%     plot(1:46,xxx(izone,:),'color',[187 187 187]./255,'linewidth',2.5,'linestyle','--');

    xlabel('Week');
    title(zoneName{izone});
    axis([1.01 45 -0.1 0.9]); % do x=1.01 because "area" function plots y=0 at beginning
    if strcmp(var,'pr_sfc')==1
        axis([14 45 -0.04 0.16]);  
    end
    set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
    set(gca,'ytick',0:0.2:1);
    if strcmp(var,'pr_sfc')==1
        set(gca,'ytick',-0.04:0.04:0.16);
    end
    set(gca,'fontsize',12);
end

p(1)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2.5);
p(2)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2.5); 
p(3)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5); 
p(4)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5);
% p(5)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5,'linestyle','--');
% p(6)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5,'linestyle','--');
% p(7)=plot([1 45],[-100 -100],'color',[187 187 187]./255,'linewidth',2.5,'linestyle','--');
legend(p,'standard','atmosphere','land',...
    'ocean','box','off','position',[.77 .3 .2 .2],'fontsize',12);
% legend(p,'standard','atmosphere','land',...
%     'ocean','atmos-land','atmos-ocean','sum','box','off','position',[.77 .3 .2 .2],'fontsize',12);

annotation('textbox',[.04 .13 .8 .1],'string','\bfMethod 1: standard - climoX (solid)',...
    'edgecolor','none','verticalalignment','bottom','fontsize',12);
annotation('textbox',[.04 .08 .8 .1],'string','\bfMethod 2: climoYclimoZ - climoALL (dotted)',...
    'edgecolor','none','verticalalignment','bottom','fontsize',12);
% annotation('textbox',[.04 .01 .8 .1],'string','\bfSum: climoALL + V_A + V_L + V_O + I_{AL} + I_{AO}',...
%     'edgecolor','none','verticalalignment','bottom','fontsize',12);

sgtitle(titleName,'fontweight','bold') 
print(printName,'-r300','-dpng');
