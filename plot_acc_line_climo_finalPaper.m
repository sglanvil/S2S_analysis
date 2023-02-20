% December 2, 2022

clear; clc; close all;

printName='ACC_line_ALLcomposite_finalPaper';

lon=0:359;
lat=-90:90;
fil='/Users/sglanvil/Documents/S2S_analysis/landsea.nc'; % downloaded from: http://www.ncl.ucar.edu/Applications/Data/#cdf
mask0=ncread(fil,'LSMASK');
lonmask=ncread(fil,'lon');
latmask=ncread(fil,'lat');
[x,y]=meshgrid(lonmask,latmask);
[xNew,yNew]=meshgrid(lon,lat); 
mask=interp2(x,y,double(mask0)',xNew,yNew,'linear',1)'; 

panelLetter={'a','b','c','d','e','f','g','h','i','j','k','l','m','n'};
subpos=[.08 .68 .20 .16; ...
    .08 .48 .20 .16; ...
    .29 .48 .20 .16; ...
    .08 .28 .20 .16; ...
    .29 .28 .20 .16; ...
    .08 .08 .20 .16; ...
    .29 .08 .20 .16; ...
    .57 .68 .20 .16; ...
    .57 .48 .20 .16; ...
    .78 .48 .20 .16; ...
    .57 .28 .20 .16; ...
    .78 .28 .20 .16; ...
    .57 .08 .20 .16; ...
    .78 .08 .20 .16; ...
    .84 .72 .14 .12;];

zoneA={'lon>190 & lon<305','lat>15 & lat<75'}; % North America (lon>190 & lon<305,lat>15 & lat<75)
zoneB={'lon>275 & lon<330','lat>-20 & lat<15'}; % South America (lon>275 & lon<330,lat>-20 & lat<15)
zoneC={'lon>345 | lon<60','lat>35 & lat<75'}; % Europe (lon>345 | lon<60,lat>35 & lat<75)
zoneD={'lon>340 | lon<60','lat>-10 & lat<35'}; % Africa (lon>340 | lon<60,lat>-10 & lat<35)
zoneE={'lon>60 & lon<145','lat>10 & lat<55'}; % Asia (lon>60 & lon<145,lat>10 & lat<55)
zoneF={'lon>95 & lon<180','lat>-50 & lat<10'}; % Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
zoneG={'lon>0 & lon<360','lat>-90 & lat<90'};
zoneList={zoneG zoneA zoneB zoneC zoneD zoneE zoneF};
zoneName={'Global' 'North America','South America','Europe',...
    'Africa','Asia','SE Asia/Australia'};

% Yellow, Green, Blue, Black, Red
lineColor=[204 187 68; 34 136 51; 102 204 238; 0 0 0; 238 102 119]./255;

% climoALLFIX --> climoALL
% climoOCNFIXclimoLND --> climoOCNclimoLND (full atmosphere)
% climoALL --> climoATMclimoLND (full ocean)
simList={'cesm2cam6climoATMv2','cesm2cam6climoLNDv2','cesm2cam6climoOCNv2',...
    'cesm2cam6v2','cesm2cam6climoOCNclimoATMv2','cesm2cam6climoALLv2',...
    'cesm2cam6climoOCNFIXclimoLNDv2','cesm2cam6climoALLFIXv2' };

icounter=0;
for ivar=1:2
    % ------------------------- SPECIFY BELOW -------------------------
    if ivar==1
        var='tas_2m'; varLong='2m Temperature'; obsName='ERA5'; timeFreq='daily';
    end
    if ivar==2
        var='pr_sfc'; varLong='Surface Precipitation'; obsName='GPCP'; timeFreq='dailySmooth';
    end
    composite='ALL'; % [ALL,DJF,JJA,EL,LA]
    scenarioName='scenario1'; % [scenario1] only
    titleName=sprintf('%s %s ACC (%s)',composite,varLong,obsName);
    % ------------------------- SPECIFY ABOVE -------------------------
    
    for izone=1:7
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
    lndFULL=squeeze(ACCsave(:,5,:));
    ocnFULL=squeeze(ACCsave(:,6,:));
    atmFULL=squeeze(ACCsave(:,7,:));
    allClim=squeeze(ACCsave(:,8,:));
    % ----------------- second method of attaining variability -----------------
    atmVar2=atmFULL-allClim;
    lndVar2=lndFULL-allClim;
    ocnVar2=ocnFULL-allClim;
    feedbackAL=lndVar2-lndVar;
    feedbackAO=ocnVar2-ocnVar;
    total=allClim+atmVar+lndVar+ocnVar+feedbackAL+feedbackAO;
    
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
    
    izoneEnd=7;
    if ivar==2
        izoneEnd=8;
    end
    for izone=1:izoneEnd
        icounter=icounter+1;
        subplot('position',subpos(icounter,:));
        izonePlot=izone;
        if izone==8
            izonePlot=1;
        end
        hold on; grid on; box on;
        area([14 28],[1 1],'edgecolor','none','facecolor',[.5 .5 .5],...
            'facealpha',0.2);
        area([14 28],[-1 -1],'edgecolor','none','facecolor',[.5 .5 .5],...
            'facealpha',0.2);
    
        plot(0:45,standard(izonePlot,:),'color',lineColor(4,:),'linewidth',2.5)
    
        area(0:45,lndVar(izonePlot,:),'edgecolor','none','facecolor',lineColor(2,:),...
            'facealpha',0.2,'linewidth',2.5); 
        plot(0:45,lndVar(izonePlot,:),'color',lineColor(2,:),'linewidth',2.5);
        area(0:45,atmVar(izonePlot,:),'edgecolor','none','facecolor',lineColor(1,:),...
            'facealpha',0.2,'linewidth',2.5);
        plot(0:45,atmVar(izonePlot,:),'color',lineColor(1,:),'linewidth',2.5);
        area(0:45,ocnVar(izonePlot,:),'edgecolor','none','facecolor',lineColor(3,:),...
            'facealpha',0.2,'linewidth',2.5);   
        plot(0:45,ocnVar(izonePlot,:),'color',lineColor(3,:),'linewidth',2.5);
        
        area(0:45,feedbackAL(izonePlot,:),'edgecolor','none','facecolor',lineColor(2,:),...
            'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
        plot(0:45,feedbackAL(izonePlot,:),'color',lineColor(2,:),'linewidth',2.5,'linestyle',':');

%         area(0:45,atmVar2(izone,:),'edgecolor','none','facecolor',lineColor(1,:),...
%             'facealpha',0.2,'linewidth',2.5,'linestyle',':');     
%         plot(0:45,atmVar2(izone,:),'color',lineColor(1,:),'linewidth',2.5,'linestyle',':');

        area(0:45,feedbackAO(izonePlot,:),'edgecolor','none','facecolor',lineColor(3,:),...
            'facealpha',0.2,'linewidth',2.5,'linestyle',':');        
        plot(0:45,feedbackAO(izonePlot,:),'color',lineColor(3,:),'linewidth',2.5,'linestyle',':');
    
        plot(0:45,total(izonePlot,:),'color',lineColor(5,:),'linewidth',2.5,'linestyle','-');
    
        time=0:45;
        maxshade=t_crit*se_save(izonePlot,:)';
        minshade=-t_crit*se_save(izonePlot,:)';
        fill([time fliplr(time)],[minshade' fliplr(maxshade')],...
            [.5 .5 .5],'facealpha',0.5,'linestyle','none');
    
        set(gca,'ytick',0:0.2:1,'yticklabel','');
        if izonePlot==1 || izonePlot==2 || izonePlot==4 || izonePlot==6
            set(gca,'ytick',0:0.2:1,'yticklabel',0:0.2:1);
            if ivar==1
                ylabel('\bfACC');
            end
        end
        if strcmp(var,'pr_sfc')==1
            set(gca,'ytick',-0.05:0.05:0.15);
            if izonePlot==1 || izonePlot==2 || izonePlot==4 || izonePlot==6
                set(gca,'ytick',-0.05:0.05:0.15,'yticklabel',-0.05:0.05:0.15);
            end
            if izone==8
                set(gca,'ytick',-0.1:0.1:0.6,'yticklabel',-0.1:0.1:0.6,...
                    'yaxislocation','left');
            end
        end
        set(gca,'xtick',0:7:70,'xticklabel','');
        if izonePlot==6 || izonePlot==7
            set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
            xlabel('\bfWeek');
        end
        if izone~=8
            title(zoneName{izonePlot});
        end
        axis([0 45 -0.1 0.9]); % do x=1.01 because "area" function plots y=0 at beginning
        if strcmp(var,'pr_sfc')==1
            axis([14 45 -0.05 0.15]);  
            if izone==8
                set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
                xtickangle(0)
                axis([0 45 -0.05 0.5]);  
                f=[1 2 3 4];
                v=[14 -0.05; 45 -0.05; 45 0.15; 14 0.15];
                patch('Faces',f,'Vertices',v,'FaceColor','none','EdgeColor',[.5 .5 .5],...
                    'linewidth',1.5);
                x = [0.89 0.77];
                y = [0.72 0.68];
                annotation('line',x,y,'linewidth',1.5,'linestyle',':','color',[.5 .5 .5]);
                x = [0.885 0.77];
                y = [0.76 0.84];
                annotation('line',x,y,'linewidth',1.5,'linestyle',':','color',[.5 .5 .5]);
            end
        end

        if ivar==1
            text(38,0.75,['(' panelLetter{icounter} ')'],'fontweight','bold');
        end
        if ivar==2 && izone~=8
            text(40,0.12,['(' panelLetter{icounter} ')'],'fontweight','bold');            
        end

        set(gca,'fontsize',10);
    end

end

p(1)=plot([1 45],[-100 -100],'color',lineColor(4,:),'linewidth',2.5);
p(2)=plot([1 45],[-100 -100],'color',lineColor(1,:),'linewidth',2.5); 
p(3)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5); 
p(4)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5);
p(5)=plot([1 45],[-100 -100],'color',lineColor(2,:),'linewidth',2.5,'linestyle',':');
p(6)=plot([1 45],[-100 -100],'color',lineColor(3,:),'linewidth',2.5,'linestyle',':');
p(7)=plot([1 45],[-100 -100],'color',lineColor(5,:),'linewidth',2.5,'linestyle','-');

lgd=legend(p,'standard','atmo','land','ocean',...
    'atmo-land','atmo-ocean','sum','box','off',...
    'location','none','position',[0.28 0.89 0.5 0.02],'fontsize',10,...
    'orientation','horizontal');

annotation('textbox',[.07 .93 .45 .05],'string','\bfTemperature',...
    'edgecolor','black','horizontalalignment','center',...
    'verticalalignment','middle','fontsize',12);

annotation('textbox',[.53 .93 .45 .05],'string','\bfPrecipitation',...
    'edgecolor','black','horizontalalignment','center',...
    'verticalalignment','middle','fontsize',12);

print(printName,'-r300','-dpng');
