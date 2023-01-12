% October 18, 2022
% based on: plot_acc_diff_climo.m

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m'; varLong='2m Temperature'; obsName='ERA5';
% var='pr_sfc'; varLong='Surface Precipitation'; obsName='GPCP';
composite='LA'; % [ALL,DJF,JJA,EL,LA]
styleType='style2'; % [style1,style2]
timeFreq='twoWeek'; % [twoWeek] only
titleName=sprintf('%s %s ACC (%s)',composite,varLong,obsName);
printName=sprintf('%s_ACC_map_%s_%scomposite_%s_figure',var,styleType,composite,obsName);
% ------------------------- SPECIFY ABOVE -------------------------
            
addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/
% addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_daily/
% addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_precip/
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
fil='landsea.nc'; % downloaded from: http://www.ncl.ucar.edu/Applications/Data/#cdf
mask=ncread(fil,'LSMASK');
lonmask=ncread(fil,'lon');
latmask=ncread(fil,'lat');
[x,y]=meshgrid(lonmask,latmask);
[xNew,yNew]=meshgrid(lon,lat);
mask=interp2(x,y,double(mask)',xNew,yNew,'linear',1)'; 
lonNew=linspace(-180,180,length(lon)); 

subpos1=[.07 .68 .22 .18; .07 .45 .22 .18; .07 .22 .22 .18];    
subpos2=[.30 .68 .22 .18; .30 .45 .22 .18; .30 .22 .22 .18];    
subpos3=[.53 .68 .22 .18; .53 .45 .22 .18; .53 .22 .22 .18];
subpos4=[.76 .68 .22 .18; .76 .45 .22 .18; .76 .22 .22 .18];
subtitle1={'(a)' '(b)' '(c)'};
subtitle2={'(d)' '(e)' '(f)'};
subtitle3={'(g)' '(h)' '(i)'};
subtitle4={'(j)' '(k)' '(l)'};
textboxdim=[.2 .5 .3 .3];
weekNames={'Weeks 1-2','Weeks 3-4','Weeks 5-6'};

% sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
% fileString1=sprintf('%s_ACC_%scomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString2=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoATMv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString3=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoLNDv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString4=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% titleNames={'standard','climoATM','climoLND','climoOCN'};

sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
fileString1=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoALLFIXv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString2=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNFIXclimoLNDv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString3=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNclimoATMv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString4=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoALLv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
titleNames={'climoALL','climoOCNclimoLND','climoOCNclimoATM','climoATMclimoLND'};

file1=dir(fullfile(sourceDir,fileString1)).name;
file2=dir(fullfile(sourceDir,fileString2)).name;
file3=dir(fullfile(sourceDir,fileString3)).name;
file4=dir(fullfile(sourceDir,fileString4)).name;

% ------------------ OLD METHOD (same result) ------------------
% file1=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6v2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file2=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoATMv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file3=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoLNDv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file4=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoOCNv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% titleNames={'standard','climoATM','climoLND','climoOCN'};
% file1=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoALLFIXv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file2=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoOCNFIXclimoLNDv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file3=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoOCNclimoATMv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% file4=sprintf('%s_ACC_%s_%sseason_%s_cesm2cam6climoALLv2.scenario1_s2s_data.nc',var,obsName,composite,timeFreq);
% titleNames={'climoALL','climoOCNclimoLND','climoOCNclimoATM','climoATMclimoLND'};

ACC1_biweekly=ncread(file1,'ACC'); 
ACC2_biweekly=ncread(file2,'ACC');
ACC3_biweekly=ncread(file3,'ACC');
ACC4_biweekly=ncread(file4,'ACC');

n=1000;
v=-2:0.05:2;
figure
for iweek=1:3

    ax(1)=subplot('position',subpos1(iweek,:));
        hold on;        
        ACC=squeeze(ACC1_biweekly(:,:,iweek));
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);
        
        % ------ plot significance (ttest for correlation) ------
        t=ACCnew./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;
        
        pcolor(lonNew,lat,ACCnew'); shading flat;
        plot(lonCoast,latCoast,'k','linewidth',1.25);
        ylabel(weekNames{iweek},'fontweight','bold');
        set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'},'fontsize',9);
        annotation('textbox',textboxdim,'String',subtitle1{iweek},'Position',...
            ax(1).Position,'Vert','bottom','fontweight','bold');

    ax(2)=subplot('position',subpos2(iweek,:));
        hold on;
        ACC=squeeze(ACC2_biweekly(:,:,iweek));
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);
        
        % ------ plot significance ------
        t=ACCnew./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;
        
        pcolor(lonNew,lat,ACCnew'); shading flat;
        plot(lonCoast,latCoast,'k','linewidth',1.25);
        set(gca,'ytick',-90:30:90,'yticklabel','');
        annotation('textbox',textboxdim,'String',subtitle2{iweek},'Position',...
            ax(2).Position,'Vert','bottom','fontweight','bold');

    ax(3)=subplot('position',subpos3(iweek,:));
        hold on;
        ACC=squeeze(ACC3_biweekly(:,:,iweek));
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);

        % ------ plot significance ------
        t=ACCnew./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;
        
        pcolor(lonNew,lat,ACCnew'); shading flat;
        plot(lonCoast,latCoast,'k','linewidth',1.25);
        set(gca,'ytick',-90:30:90,'yticklabel','');
        annotation('textbox',textboxdim,'String',subtitle3{iweek},'Position',...
            ax(3).Position,'Vert','bottom','fontweight','bold');

    ax(4)=subplot('position',subpos4(iweek,:));
        hold on;
        ACC=squeeze(ACC4_biweekly(:,:,iweek));
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);
        
        % ------ plot significance ------
        t=ACCnew./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;
        
        pcolor(lonNew,lat,ACCnew'); shading flat;
        plot(lonCoast,latCoast,'k','linewidth',1.25);
        set(gca,'ytick',-90:30:90,'yticklabel','');
        annotation('textbox',textboxdim,'String',subtitle4{iweek},'Position',...
            ax(4).Position,'Vert','bottom','fontweight','bold');
        
    for i=1:length(ax)
        set(ax(i),'xtick',-180:90:180,'xticklabel',[]);
        if iweek==1
            title(ax(i),titleNames{i},'fontweight','bold','fontsize',10)
            caxis(ax(i),[-1 1]);
        end
        if iweek==2
            caxis(ax(i),[-1 1]);            
        end
        if iweek==3
            set(ax(i),'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' ' '},'fontsize',9);
            xtickangle(ax(i),45)
            caxis(ax(i),[-1 1]);
        end
        set(ax(i),'box','on','layer','top');
        set(ax(i),'fontsize',9);
        axis(ax(i),[-180 180 -60 90]);
        colormap(ax(i),gradsmap);
    end
end
cb=colorbar('location','southoutside','position',[.30 .1 .45 .03]);
set(cb,'xtick',-1:0.2:1); ylabel(cb,'\bfACC','fontsize',10);

sgtitle(titleName,'fontweight','bold') 
print(printName,'-r300','-dpng');
