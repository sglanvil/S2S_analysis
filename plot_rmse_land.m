% February 20, 2023
% located: /Users/sglanvil/Documents/S2S_climo_experiments
clear; clc; close all;

printName=sprintf('/glade/work/sglanvil/CCR/S2S/figures/H2OSOI_response_RMSE_map_ALL');

gradsmap=flip([103 0 31; 178 24 43; 214 96 77; 244 165 130; 253 219 199; ...
    209 229 240; 146 197 222; 67 147 195; 33 102 172; 5 48 97]/256);
gradsmap1=interp1(1:5,gradsmap(1:5,:),linspace(1,5,10));
gradsmap2=interp1(6:10,gradsmap(6:10,:),linspace(6,10,10));
gradsmap=[gradsmap1; gradsmap2];

subplotNumber=[1 3 5 2 4 6];
expList={'standard' 'climoLND' 'climoOCNclimoATM'};
for iexp=1:3
    exp=expList{iexp};
    exp
    dir=sprintf('/glade/campaign/cesm/development/cross-wg/S2S/sglanvil/forSanjiv/H2OSOI_%s/',exp);
    titleName=sprintf('%s SM (day5-day0) RMSE',exp);
    
    if strcmp(exp,'standard')
        exp=''; % if doing standard, remove exp name for file0 and file5
    end
    file0=[dir 'H2OSOI_cesm2cam6' exp 'v2.00.clm2.h0.ALL.time0.nc'];
    file5=[dir 'H2OSOI_cesm2cam6' exp 'v2.00.clm2.h0.ALL.time5.nc'];
    
    % read in variables
    h2osoi0=squeeze(ncread(file0,'H2OSOI',[1 1 1 1],[Inf Inf 7 Inf])); % top levs
    h2osoi5=squeeze(ncread(file5,'H2OSOI',[1 1 1 1],[Inf Inf 7 Inf])); % top levs
    dzsoi0=squeeze(ncread(file0,'DZSOI',[1 1 1 1],[Inf Inf 7 Inf]))*1000; % top levs
    dzsoi5=squeeze(ncread(file5,'DZSOI',[1 1 1 1],[Inf Inf 7 Inf]))*1000; % top levs
    lon=ncread(file0,'lon');
    lat=ncread(file0,'lat');
    date=int2str(ncread(file0,'mcdate'));
    time=datetime(date,'InputFormat','uuuuMMdd');
    
    % Soil Moisture (SM) weighted average (first 7 levels: 0.68 meters)
    % soil thickness example: dzsoi(66,130,:,1): 0.02, 0.04, 0.06, 0.08, 0.12, 0.16, 0.2 meters
    SM_weighted0=squeeze(sum(h2osoi0.*dzsoi0,3,'omitnan')./sum(dzsoi0,3,'omitnan'));
    SM_weighted5=squeeze(sum(h2osoi5.*dzsoi5,3,'omitnan')./sum(dzsoi5,3,'omitnan'));
    
    % calculate RMSE for day5-day0
    RMSE=sqrt(mean((SM_weighted5-SM_weighted0).^2,3,'omitnan'));
    RMSE_save(:,:,iexp)=RMSE;
    
    ax(iexp)=subplot(3,2,subplotNumber(iexp));
    pcolor(lon,lat,RMSE'); shading flat;
    colormap(gradsmap);
    title(titleName);
end

subplotNumber=[4 6];
titleName={'climoLND-standard' 'climoOCNclimoATM-standard'};
for iexp=1:2
    titleName(iexp)
    ax(iexp+3)=subplot(3,2,subplotNumber(iexp));
    RMSE=squeeze(RMSE_save(:,:,iexp+1)-RMSE_save(:,:,1));
    pcolor(lon,lat,RMSE'); shading flat;
    colormap(gradsmap);
    title(titleName(iexp));
end

clim(ax(1),[-0.04 0.04]);
clim(ax(2),[-0.04 0.04]);
clim(ax(3),[-0.04 0.04]);
clim(ax(4),[-0.04 0.04]);
clim(ax(5),[-0.04 0.04]);

hc=colorbar('location','southoutside','position',[0.625 0.75 0.25 0.02]);
ylabel(hc,'Soil Moisture RMSE (mm3/mm3)')
set(gcf,'renderer','painters')

print(printName,'-r300','-dpng');
