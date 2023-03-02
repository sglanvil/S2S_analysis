% December 17, 2022
clear; clc; close all;

printName='hypothesis_ACC_line_daily';

x=0:12;
xN=linspace(0,12,46);
yOCN=[0.0 0.1 0.2 0.4 0.6 0.9 1.2 1.8 2.5 3.1 3.8 4.2 4.5]/15;
yLND=[0.0 3.9 5.6 5.9 5.6 5.1 4.6 4.0 3.5 3.0 2.6 2.3 2.1]/15;
yATM=[15 11.6 7.4 4.5 2.9 1.9 1.4 1.1 1.0 0.9 0.8 0.7 0.6]/15;
yOCN=movmean(interp1(x,yOCN,xN),2);
yLND=movmean(interp1(x,yLND,xN),2);
yATM=movmean(interp1(x,yATM,xN),2);

lineColor=[204 187 68; 34 136 51; 102 204 238; 0 0 0]./255;

figure
hold on; grid on; box on;
area([14 28],[1 1],'edgecolor','none','facecolor',[120 120 120]/255,...
    'facealpha',0.1);
area([14 28],[-1 -1],'edgecolor','none','facecolor',[120 120 120]/255,...
    'facealpha',0.1);
area(1:46,yLND,'edgecolor','none','facecolor',lineColor(2,:),...
    'facealpha',0.2,'linewidth',2.5); 
plot(1:46,yLND,'color',lineColor(2,:),'linewidth',2.5);
area(1:46,yATM,'edgecolor','none','facecolor',lineColor(1,:),...
    'facealpha',0.2,'linewidth',2.5);
plot(1:46,yATM,'color',lineColor(1,:),'linewidth',2.5);
area(1:46,yOCN,'edgecolor','none','facecolor',lineColor(3,:),...
    'facealpha',0.2,'linewidth',2.5);   
plot(1:46,yOCN,'color',lineColor(3,:),'linewidth',2.5);

text(7,0.8,'atmosphere','color',lineColor(1,:),'fontsize',15,'fontweight','bold');
text(20,0.4,'land','color',lineColor(2,:),'fontsize',15,'fontweight','bold');
text(38,0.32,'ocean','color',lineColor(3,:),'fontsize',15,'fontweight','bold');

xlabel('\bfWeek');
ylabel('\bfPredictability');
set(gca,'xtick',0:7:70,'xticklabel',0:1:7);
set(gca,'ytick',0:0.2:1);
axis([1.01 45 0 1]); % do x=1.01 because "area" function plots y=0 at beginning
set(gca,'fontsize',15);

print(printName,'-r300','-dpng');
