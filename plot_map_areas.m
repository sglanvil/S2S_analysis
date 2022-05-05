% May 5, 2022
clear; clc; close all;

load('coast.mat');
latCoast=lat;
lonCoast=long;

figure;
subplot('position',[.1 .2 .8 .6]);
hold on; box on;
plot(lonCoast,latCoast,'k','linewidth',1);
set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'});
set(gca,'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' '180E'});
xtickangle(45)
axis([-180 180 -60 90]);

% North America (lon>190 & lon<305,lat>15 & lat<75)
x=[-170 -55 -55 -170]; % (deg east)-360
y=[15 15 75 75];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

% South America 
x=[-85 -30 -30 -85]; 
y=[-20 -20 15 15];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

% Asia
x=[60 145 145 60];
y=[10 10 55 55];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

% Europe
x=[-10 60 60 -10];
y=[35 35 75 75];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

% Australia/SE Asia
x=[95 180 180 95];
y=[-50 -50 10 10];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

% Africa
x=[-20 60 60 -20];
y=[-10 -10 35 35];
patch(x,y,'blue','facealpha',0.25,'linestyle','-');

