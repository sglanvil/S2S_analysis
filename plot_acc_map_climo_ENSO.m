% February 1, 2023

% ------------------ 2 columns x 3 rows ------------------
% standard:                     Neutral | Active-Neutral
% climoATMclimoLND - standard:  Neutral | Active-Neutral
% climoOCN - standard:          Neutral | Active-Neutral
% --------------------------------------------------------

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m'; varLong='2m Temperature'; obsName='ERA5';
% var='pr_sfc'; varLong='Surface Precipitation'; obsName='GPCP';
timeFreq='twoWeek'; % [twoWeek] only
titleName=sprintf('Active - Neutral (ALL seasons) %s ACC',varLong);
printName=sprintf('%s_ACC_map_ACTIVEminusNEUTRAL_ENSO_finalPaper_figure',var);
% ------------------------- SPECIFY ABOVE -------------------------

addpath /Users/sglanvil/Documents/S2S/     
addpath /Users/sglanvil/Documents/S2S_analysis/
addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_daily/
addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/
gradsmap=sg_gradsmap_odd;
gradsmap(9:11,:)=[]; % remove white
gradsmap1=interp1(1:8,gradsmap(1:8,:),linspace(1,8,10));
gradsmap2=interp1(9:17,gradsmap(9:17,:),linspace(9,17,10));
gradsmap=[gradsmap1; gradsmap2];

load('coast.mat');
latCoast=lat;
lonCoast=long;
fil='tas_2m_ACC_DJFseason_daily_cesm2cam6v2.scenario1_s2s_data.nc';
lon=ncread(fil,'lon');
lat=ncread(fil,'lat');
lonNew=linspace(-180,180,length(lon)); 

subpos=[.22 .72 .34 .22; .22 .45 .34 .22; .22 .18 .34 .22];    


subpos(:,1,:)=subpos(:,1,:)+0.12;

weekNames={'Weeks 1-2','Weeks 3-4','Weeks 5-6'};

sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
fileString1=sprintf('%s_ACC_ENSOACTIVEcomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
fileString2=sprintf('%s_ACC_ENSOACTIVEcomposite_%s_cesm2cam6climoOCNv2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
fileString3=sprintf('%s_ACC_ENSOACTIVEcomposite_%s_cesm2cam6climoALLv2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
file1=dir(fullfile(sourceDir,fileString1)).name;
file2=dir(fullfile(sourceDir,fileString2)).name;
file3=dir(fullfile(sourceDir,fileString3)).name;
ACC1_active=ncread(file1,'ACC'); 
ACC2_active=ncread(file2,'ACC');
ACC3_active=ncread(file3,'ACC');

fileString1=sprintf('%s_ACC_ENSONEUTRALcomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
fileString2=sprintf('%s_ACC_ENSONEUTRALcomposite_%s_cesm2cam6climoOCNv2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
fileString3=sprintf('%s_ACC_ENSONEUTRALcomposite_%s_cesm2cam6climoALLv2.scenario1_*sample_%s_s2s_data.nc',var,timeFreq,obsName);
file1=dir(fullfile(sourceDir,fileString1)).name;
file2=dir(fullfile(sourceDir,fileString2)).name;
file3=dir(fullfile(sourceDir,fileString3)).name;
ACC1_neutral=ncread(file1,'ACC'); 
ACC2_neutral=ncread(file2,'ACC');
ACC3_neutral=ncread(file3,'ACC');

% ACC1_biweekly=ACC1_active;
% ACC2_biweekly=ACC2_active;
% ACC3_biweekly=ACC3_active;

ACC1_biweekly=ACC1_active-ACC1_neutral;
ACC2_biweekly=ACC2_active-ACC2_neutral;
ACC3_biweekly=ACC3_active-ACC3_neutral;
ACC_save=cat(4,ACC1_biweekly,ACC2_biweekly,ACC3_biweekly);
% titleNames={'standard','climoOCN','climoATMclimoLND'};
titleNames={'Active - Neutral ENSO'};
subtitleALL={'(a)' '(b)' '(c)'};

figure
for iweek=1:3
    for icase=1
        ax(icase)=subplot('position',subpos(iweek,:));
        hold on; box on;   

        ACC=squeeze(ACC_save(:,:,iweek,icase));
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);
%         ------ plot significance (ttest for correlation) ------
        n=500;
        t=abs(ACCnew)./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;

        contourf(lonNew,lat,ACCnew',-1:0.1:1,'linestyle','none'); 
        clim([-1 1]); colormap(gradsmap)
        plot(lonCoast,latCoast,'k','linewidth',1);

        set(gca,'box','on','layer','top');
        set(gca,'xtick',-180:90:180,'xticklabel',[]);
        set(gca,'ytick',-90:30:90,'yticklabel',[]);        
        if icase==1
            ylabel(weekNames{iweek},'fontweight','bold');
            set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'},'fontsize',10);
        end
        if iweek==1
            title(titleNames{icase},'fontweight','bold','fontsize',13);
        end
        if iweek==3
            set(gca,'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' '180E'},'fontsize',10);
            xtickangle(45)
        end       
        axis([-180 180 -60 90]);
    end
    textboxdim=[.2 .5 .3 .3];
    annotation('textbox',textboxdim,'String',subtitleALL{iweek},'Position',...
        gca().Position,'Vert','bottom','fontweight','bold','fontsize',12);
end
cb=colorbar('location','southoutside','position',[.30 .08 .42 .03]);
set(cb,'xtick',-1:0.2:1,'fontsize',8); ylabel(cb,'\bfACC','fontsize',10);
set(gcf,'renderer','painters')
% sgtitle('Active - Neutral ENSO','fontweight','bold') 
print(printName,'-r300','-dpng');
