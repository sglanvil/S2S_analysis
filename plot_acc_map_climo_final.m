% October 18, 2022
% based on: plot_acc_diff_climo.m

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
% var='pr_sfc'; 
% titleName='Precipitation';

var='tas_2m';
titleName='2m Temperature';

season='DJF';

printName=sprintf('%s_ACC_map_diff_%sseason_var2_figure',var,season);
% printName=sprintf('%s_ACC_map_diff_%sseason_var_figure',var,season);
% ------------------------- SPECIFY ABOVE -------------------------

addpath /Users/sglanvil/Documents/S2S_climo_experiments/ACC_daily/
gradsmap=sg_gradsmap_odd;
gradsmap(10:11,:)=[]; % remove white
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

subpos1=[.08 .65 .25 .2; .08 .4 .25 .2; .08 .15 .25 .2];    
subpos2=[.38 .65 .25 .2; .38 .4 .25 .2; .38 .15 .25 .2];    
subpos3=[.68 .65 .25 .2; .68 .4 .25 .2; .68 .15 .25 .2];
subtitle1={'(a)' '(b)' '(c)'};
subtitle2={'(d)' '(e)' '(f)'};
subtitle3={'(g)' '(h)' '(i)'};
textboxdim=[.2 .5 .3 .3];
weekNames={'Weeks 1-2','Weeks 3-4','Weeks 5-6'};

% -------------- var from method #1 --------------
fil0=sprintf('%s_ACC_%sseason_daily_cesm2cam6v2.scenario1_s2s_data.nc',var,season);
fil1=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoATMv2.scenario1_s2s_data.nc',var,season);
fil2=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoLNDv2.scenario1_s2s_data.nc',var,season);
fil3=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoOCNv2.scenario1_s2s_data.nc',var,season);
titleNames={'standard - climoATM','standard - climoLND','standard - climoOCN'};
% -------------- var from method #2 --------------
% fil0=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoALLFIXv2.scenario1_s2s_data.nc',var,season);
% fil1=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoOCNFIXclimoLNDv2.scenario1_s2s_data.nc',var,season);
% fil2=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoOCNclimoATMv2.scenario1_s2s_data.nc',var,season);
% fil3=sprintf('%s_ACC_%sseason_daily_cesm2cam6climoALLv2.scenario1_s2s_data.nc',var,season);
% titleNames={'climoOCNclimoLND - climoALL','climoOCNclimoATM - climoALL','climoATMclimoLND - climoALL'};


ACC_CTRL=ncread(fil0,'ACC');
ACC_ATM=ncread(fil1,'ACC');
ACC_LND=ncread(fil2,'ACC');
ACC_OCN=ncread(fil3,'ACC');
icounter=0;
for week=[1 3 5]
    icounter=icounter+1;
    ACC_CTRL_biweekly(:,:,icounter)=squeeze(nanmean(...
        ACC_CTRL(:,:,(week-1)*7+1+1:(week-1)*7+14+1,:),3)); 
    ACC_ATM_biweekly(:,:,icounter)=squeeze(nanmean(...
        ACC_ATM(:,:,(week-1)*7+1+1:(week-1)*7+14+1,:),3)); 
    ACC_LND_biweekly(:,:,icounter)=squeeze(nanmean(...
        ACC_LND(:,:,(week-1)*7+1+1:(week-1)*7+14+1,:),3)); 
    ACC_OCN_biweekly(:,:,icounter)=squeeze(nanmean(...
        ACC_OCN(:,:,(week-1)*7+1+1:(week-1)*7+14+1,:),3)); 
end
                
% -------------- var from method #1 --------------
ACC_ATMvar=ACC_CTRL_biweekly-ACC_ATM_biweekly; 
ACC_LNDvar=ACC_CTRL_biweekly-ACC_LND_biweekly;
ACC_OCNvar=ACC_CTRL_biweekly-ACC_OCN_biweekly;
% -------------- var from method #2 --------------
% ACC_ATMvar=ACC_ATM_biweekly-ACC_CTRL_biweekly; 
% ACC_LNDvar=ACC_LND_biweekly-ACC_CTRL_biweekly; 
% ACC_OCNvar=ACC_OCN_biweekly-ACC_CTRL_biweekly; 

v=-2:0.05:2;
for iweek=1:3

    ax(1)=subplot('position',subpos1(iweek,:));
        hold on;
        ACC=squeeze(ACC_ATMvar(:,:,iweek));
        ACC(mask==0)=NaN;
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        contourf(lonNew,lat,ACCnew',v,'linestyle','none');
        caxis([-0.45 0.45]); 
        cb=colorbar('location','southoutside','position',[subpos1(1,1) .06 .25 .02]);
        set(cb,'xtick',-1:0.1:1); ylabel(cb,'\bfACC');
        plot(lonCoast,latCoast,'k');
        ylabel(weekNames{iweek},'fontweight','bold');
        set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'},'fontsize',9);
        annotation('textbox',textboxdim,'String',subtitle1{iweek},'Position',...
            ax(1).Position,'Vert','bottom','fontweight','bold');

    ax(2)=subplot('position',subpos2(iweek,:));
        hold on;
        ACC=squeeze(ACC_LNDvar(:,:,iweek));
        ACC(mask==0)=NaN;
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        contourf(lonNew,lat,ACCnew',v,'linestyle','none');
        caxis([-0.45 0.45]);
        cb=colorbar('location','southoutside','position',[subpos2(1,1) .06 .25 .02]);
        set(cb,'xtick',-1:0.1:1); ylabel(cb,'\bfACC');
        plot(lonCoast,latCoast,'k');
        set(gca,'ytick',-90:30:90,'yticklabel','');
        annotation('textbox',textboxdim,'String',subtitle2{iweek},'Position',...
            ax(2).Position,'Vert','bottom','fontweight','bold');

        ax(3)=subplot('position',subpos3(iweek,:));
            hold on;
            ACC=squeeze(ACC_OCNvar(:,:,iweek));
            ACC(mask==0)=NaN;
            ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
            contourf(lonNew,lat,ACCnew',v,'linestyle','none');
            caxis([-0.45 0.45]);
            cb=colorbar('location','southoutside','position',[subpos3(1,1) .06 .25 .02]);
            set(cb,'xtick',-1:0.1:1); ylabel(cb,'\bfACC');
            plot(lonCoast,latCoast,'k');
            set(gca,'ytick',-90:30:90,'yticklabel','');
            annotation('textbox',textboxdim,'String',subtitle3{iweek},'Position',...
                ax(3).Position,'Vert','bottom','fontweight','bold');

    for i=1:length(ax)
        set(ax(i),'xtick',-180:90:180,'xticklabel',[]);
        if iweek==1
            title(ax(i),titleNames{i},'fontweight','bold','fontsize',10)
        end
        if iweek==3
            set(ax(i),'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' '180E'},'fontsize',9);
            xtickangle(ax(i),45)
        end
        set(ax(i),'box','on','layer','top');
        set(ax(i),'fontsize',9);
        axis(ax(i),[-180 180 -60 90]);
        colormap(ax(i),gradsmap);
    end
end

sgtitle(sprintf('%s %s',season,titleName),'fontweight','bold');
print(printName,'-r300','-dpng');
