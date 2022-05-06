% May 5, 2022
clear; clc; close all;

printName='map_areas_figure';

load('coast.mat');
latCoast=lat;
lonCoast=long;

figure;
subplot('position',[.1 .2 .8 .6]);
hold on; box on;
plot(lonCoast,latCoast,'k','linewidth',1.5);

% 1. North America (lon>190 & lon<305,lat>15 & lat<75)
x=[-170 -55 -55 -170]; % (deg east)-360
y=[15 15 75 75];
patch(x,y,'blue','facealpha',0.35,'linestyle','-');
text((-170+-55)/2,(15+75)/2,'1','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

% 2. South America (lon>275 & lon<330,lat>-20 & lat<15)
x=[-85 -30 -30 -85]; 
y=[-20 -20 15 15];
patch(x,y,'red','facealpha',0.35,'linestyle','-');
text((-85+-30)/2,(-20+15)/2,'2','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

% 3. Europe (lon>0 & lon<60 & lon>345,lat>35 & lat<75)
x=[-15 60 60 -15];
y=[35 35 75 75];
patch(x,y,'yellow','facealpha',0.35,'linestyle','-');
text((-15+60)/2,(35+75)/2,'3','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

% 4. Africa (lon>0 & lon<60 & lon>340,lat>-10 & lat<35)
x=[-20 60 60 -20];
y=[-10 -10 35 35];
patch(x,y,'green','facealpha',0.35,'linestyle','-');
text((-20+60)/2,(-10+35)/2,'4','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

% 5. Asia (lon>60 & lon<145,lat>10 & lat<55)
x=[60 145 145 60];
y=[10 10 55 55];
patch(x,y,'magenta','facealpha',0.35,'linestyle','-');
text((60+145)/2,(10+55)/2,'5','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

% 6. Australia/SE Asia (lon>95 & lon<180,lat>-50 & lat<10)
x=[95 180 180 95];
y=[-50 -50 10 10];
patch(x,y,'cyan','facealpha',0.35,'linestyle','-');
text((95+180)/2,(-50+10)/2,'6','fontsize',20,'fontweight','bold','color','black','horizontalalignment','center');

set(gca,'ytick',-90:30:90,'yticklabel',{'90S' '60S' '30S' '0' '30N' '60N' '90N'});
set(gca,'xtick',-180:90:180,'xticklabel',{'180W' '90W' '0' '90E' '180E'});
xtickangle(45)
axis([-180 180 -60 90]);
set(gca,'fontsize',13);

print(printName,'-r300','-dpng');
