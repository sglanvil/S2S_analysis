% October 18, 2022
% based on: plot_acc_diff_climo.m

clear; clc; close all;

% ------------------------- SPECIFY BELOW -------------------------
var='tas_2m'; varLong='2m Temperature'; obsName='ERA5';
% var='pr_sfc'; varLong='Surface Precipitation'; obsName='GPCP';
composite='LA'; % [ALL,DJF,JJA,EL,LA,ENSOACTIVE]
styleType='style2'; % [style1,style2,style3]
timeFreq='twoWeek'; % [twoWeek] only
titleName=sprintf('%s %s ACC (%s)',composite,varLong,obsName);
printName=sprintf('%s_ACC_map_%s_%scomposite_%s_figure',var,styleType,composite,obsName);
% printName=sprintf('%s_ACCdiff_map_%s_%scomposite_%s_figure',var,styleType,composite,obsName);
% ------------------------- SPECIFY ABOVE -------------------------

addpath /Users/sglanvil/Documents/S2S/     
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
subposALL=cat(3,subpos1,subpos2,subpos3,subpos4);

% subtitle1={'(a)' '(b)' '(c)'};
% subtitle2={'(d)' '(e)' '(f)'};
% subtitle3={'(g)' '(h)' '(i)'};
% subtitle4={'(j)' '(k)' '(l)'};

subtitle1={'(m)' '(n)' '(o)'};
subtitle2={'(p)' '(q)' '(r)'};
subtitle3={'(s)' '(t)' '(u)'};
subtitle4={'(v)' '(w)' '(x)'};

subtitleALL=cat(1,subtitle1,subtitle2,subtitle3,subtitle4);
textboxdim=[.2 .5 .3 .3];
weekNames={'Weeks 1-2','Weeks 3-4','Weeks 5-6'};

sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
fileString0=sprintf('%s_ACC_%scomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString1=sprintf('%s_ACC_%scomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString2=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoATMv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString3=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoLNDv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
fileString4=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
titleNames={'standard','climoATM','climoLND','climoOCN'};

% sourceDir='/Users/sglanvil/Documents/S2S_climo_experiments/ACC_final/';
% fileString0=sprintf('%s_ACC_%scomposite_%s_cesm2cam6v2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString1=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoALLFIXv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString2=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNFIXclimoLNDv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString3=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoOCNclimoATMv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% fileString4=sprintf('%s_ACC_%scomposite_%s_cesm2cam6climoALLv2.scenario1_*sample_%s_s2s_data.nc',var,composite,timeFreq,obsName);
% titleNames={'climoALL','climoOCNclimoLND','climoOCNclimoATM','climoATMclimoLND'};

file0=dir(fullfile(sourceDir,fileString0)).name;
file1=dir(fullfile(sourceDir,fileString1)).name;
file2=dir(fullfile(sourceDir,fileString2)).name;
file3=dir(fullfile(sourceDir,fileString3)).name;
file4=dir(fullfile(sourceDir,fileString4)).name;

ACC0=ncread(file0,'ACC'); 

ACC1=ncread(file1,'ACC'); 
ACC2=ncread(file2,'ACC');
ACC3=ncread(file3,'ACC');
ACC4=ncread(file4,'ACC');
ACC1diff=ACC1-ACC0;
ACC2diff=ACC2-ACC0;
ACC3diff=ACC3-ACC0;
ACC4diff=ACC4-ACC0;

n=1000;
figure
for iweek=1:3
    for icase=1:4
        subplot('position',subposALL(iweek,:,icase));
        hold on;
        ACCin=eval(sprintf('ACC%.1d',icase));
        ACCdiffin=eval(sprintf('ACC%.1ddiff',icase));
        % grab each week
        ACC=squeeze(ACCin(:,:,iweek));
        ACCdiff=squeeze(ACCdiffin(:,:,iweek));
        ACCdiff(abs(ACCdiff)>1)=NaN;
        % rearrange
        ACCnew=[ACC(lon>=180 & lon<=360,:); ACC(lon>=0 & lon<180,:)];
        ACCnew(181,:)=ACCnew(182,:);
        ACCdiffnew=[ACCdiff(lon>=180 & lon<=360,:); ACCdiff(lon>=0 & lon<180,:)];
        ACCdiffnew(181,:)=ACCdiffnew(182,:);

        % statistical significance (t-test)
        t=abs(ACCnew)./sqrt((1-ACCnew.^2)/(n-2));
        p=tcdf(t,n-2);        
        ACCnew(p<0.975)=NaN;
        
        t=abs(ACCdiffnew)./sqrt((1-ACCdiffnew.^2)/(n-2)); % WARNING: IMAGINARY NUMBERS?
        p=tcdf(t,n-2);    
        ACCdiffnew(p<0.975)=1; % not significantly different from standard
        ACCdiffnew(p>=0.975)=0; % yes signifciantly different from standard

        contourf(lonNew,lat,ACCnew',-1:0.1:1,'linestyle','none'); 
        clim([-1 1]); colormap(gradsmap)
        plot(lonCoast,latCoast,'k','linewidth',1);

        if icase>1
            ACCdiffnew(isnan(ACCdiffnew))=1;
            mask=logical(ACCdiffnew);
            [x,y]=meshgrid(lonNew,lat);
            stipple(x,y,mask','color',[.5 .5 .5],'density',100,'markersize',2,'marker','x');
        end

        set(gca,'box','on','layer','top');
        set(gca,'xtick',-180:90:180,'xticklabel',[]);
        set(gca,'ytick',-90:30:90,'yticklabel',[]);        
        set(gca,'fontsize',9);
        if icase==1
            ylabel(weekNames{iweek},'fontweight','bold');
            set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'},'fontsize',9);
        end
        if iweek==1
            title(titleNames{icase},'fontweight','bold','fontsize',10);
        end
        if iweek==3
            set(gca,'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' ' '},'fontsize',9);
            xtickangle(45)
        end       
        axis([-180 180 -60 90]);
        annotation('textbox',textboxdim,'String',subtitleALL{icase,iweek},'Position',...
            gca().Position,'Vert','bottom','fontweight','bold');
    end
end
cb=colorbar('location','southoutside','position',[.30 .1 .45 .03]);
set(cb,'xtick',-1:0.2:1); ylabel(cb,'\bfACC','fontsize',10);
sgtitle(titleName,'fontweight','bold') 
set(gcf,'renderer','painters')
% print(printName,'-r300','-dpng');
