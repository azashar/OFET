clc; clear all; close all;
[filename, pathname] = uigetfile({'*.*',  'All Files (*.*)'},'Pick a file');
fid = fopen(filename);
C = textscan(fid,'%s %s %s %s');
fclose(fid);
[m n]=size(C{1});
t=double(0);
mm=m-3;

file2525=zeros(mm,2);
for i=1:2
    for j=1:mm
        temp=str2double(C{i}{j+3});
        file2525(i,j)=temp;
    end
end
file225=file2525(1:2,:);
file=transpose(file225);
file(:,2)=(abs(file(:,2))*1E-6);

prompt = {'Type (n/p)','Capacitance per unit area (nF/cm^2):','Length (microns)','Width (mm)','Vds (V)'};
dlg_title = 'Enter transistor physical parameters';
num_lines = 1;
def = {'n','4','100','1','80'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
t= answer{1};
C=str2double(answer{2});
L=str2double(answer{3});
W=str2double(answer{4});
Vds=str2double(answer{5});

x=(file(:,1));
y=(file(:,2));
ysqrt=sqrt(y);
ylog=log(y);

scrsz = get(0,'ScreenSize'); % get screen size
figure('Position',[200 scrsz(4)/12 scrsz(4)/1.2 scrsz(4)/1.3]);
[AX,H1,H2] = plotyy(x,ylog,x,ysqrt,'semilogy','plot');
set(AX,'FontSize',20);

if(t=='p')
    set(AX,'Xdir','reverse');
end;

xlabel('V_{GS}(V)');
title('I_{DS}V_{GS}');
set(get(AX(1),'Ylabel'),'String','I_{DS}(A)','fontsize',14);
set(get(AX(2),'Ylabel'),'String','I_{DS}^{1/2}(A)^{1/2}','fontsize',14);
set(H1,'Marker','^','LineStyle','--','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',8);
set(H2,'Marker','v','LineStyle','--','LineWidth',1,'MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',8);

set(AX(1),'ytick',linspace(min(y),max(y),4),'YLimMode','auto');
set(AX(2),'ytick',linspace(min(ysqrt),max(ysqrt),4),'YlimMode','auto');
%set(AX(1),'FontSize',10);

%set(AX(1),'ylim',[min(ylog) max(ylog)]);
%set(AX(2),'ylim',[min(ysqrt) max(ysqrt)]);





%int = getpoint('Click on the axis intersection point');
[xr,yr] = ginput(2);          % take two (2) (x,y) values as (xr(1),yr(1)) and (xr(2),yr(2))
[~,I] = min(abs(x-(xr(1))));  % give the index I of the value in x matrix, which is close to value xr(1)
l= x(I);
[~,I] = min(abs(x-(xr(2))));
h = x(I);

scrsz = get(0,'ScreenSize');
figure('Position',[400 scrsz(4)/5 scrsz(4)/0.8 scrsz(4)/1.6]);
subplot(2,2,[1 2]);
[AX,H1,H2] = plotyy(x,y,x,ysqrt,@plot);
if(t=='p')
    set(AX,'Xdir','reverse');
end;
set(AX(1),'ytick',linspace(min(y),max(y),4),'YLimMode','auto');
set(AX(2),'ytick',linspace(min(ysqrt),max(ysqrt),4),'YlimMode','auto');
%ylim(AX(1),[min(y) max(y)]);
%ylim(AX(2),[min(ysqrt) max(ysqrt)]);

set(get(AX(1),'Ylabel'),'String','I_{DS}(A)');
set(get(AX(2),'Ylabel'),'String','I_{DS}^{1/2}(A)^{1/2}');
xlabel('V_{GS}(V)');
title('I_{DS}V_{GS}'); 
set(H1,'Marker','^','LineStyle','--','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',8);
set(H2,'Marker','v','LineStyle','--','LineWidth',1,'MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',8);
%int = getpoint('Click on the axis intersection point');

subplot(2,2,3);
title('Entered physical parameters');
set(gca,'xtick',[]);
set(gca,'ytick',[]);
text(0.1,0.5, sprintf('Type %c \n\n Capacitance, C_{i}= %g nF/cm^{2} \n Length= %g (micron) \n Width= %g (mm) \n Lower limit = %g V \n Upper limit = %g V \n V_{DS}= %i V',t,C,L,W,l,h,80.0));

ll=find(x==l); % finding the index l1 corresponding to l value in x matrix
hl=find(x==h);
n=hl-ll;       % finding the number of values between the indices l1 and h1
xclm=double(x(ll:hl));
yclm=double(ysqrt(ll:hl));

p=polyfit(xclm,yclm,1);    % polyfit(... , ... , 1) will give linear fit, with p(1) as the slope
% m=p;                       % m is the slope of the fit in the saturation region
Smob=(2*L*1E-3)*((p(1))^2)/((C*1E-9)*(W*1E-1));

Vt=p(2)/p(1);

OnOFF=abs(max(y))/abs(min(y));



subplot(2,2,4);
title('Measured physical parameters');
set(gca,'xtick',[]);
set(gca,'ytick',[]);
text(0.05,0.6, sprintf('Slope, S= %e  \n Sat.Mobility= %e cm^{2}/(Vs) \n Intercept= %g  \n On/Off ratio= %e \n Threshold voltage, Vt= %e' ,p(1),Smob,p(2),OnOFF,Vt));
