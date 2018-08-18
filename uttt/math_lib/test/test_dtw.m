clc;
close all;
clear;

dtw_fun = @my_dtw;

t1 = 0:0.01:1;
t2 = 0:0.05:2;

x1 = sin(0.7*t1);
x2 = sin(0.6*t2) + 0.1*exp(-20*t2);

% x1 = [0 1 0 0 0 0 0 0 0 0 0 1 0]*.95;
% x2 = [0 1 0 1 0]*.95;

t1 = 1:length(x1);
t2 = 1:length(x2);

[dist,ix1,ix2] = dtw_fun(x1,x2);

y1 = x1(ix1);
y2 = x2(ix2);

t = 1:length(ix1);

fontsize = 14;

figure;
plot(t,ix1,t,ix2);
legend({'$ix_1$','$ix_2$'},'Interpreter','latex','fontsize',fontsize);
title('Matching indices','Interpreter','latex','fontsize',fontsize);

figure;
subplot(3,1,1);
plot(t1,x1,t2,x2);
legend({'$x_1$','$x_2$'},'Interpreter','latex','fontsize',fontsize);
title('Initial signals','Interpreter','latex','fontsize',fontsize);
axis tight;
subplot(3,1,2);
plot(t,y1,t,y2);
legend({'$y_1$','$y_2$'},'Interpreter','latex','fontsize',fontsize);
title('Signals after $DTW$','Interpreter','latex','fontsize',fontsize);
axis tight;
subplot(3,1,3);
plot(t,y1-y2);
legend({'$e=y_1-y_2$'},'Interpreter','latex','fontsize',fontsize);
title('$DTW$ error','Interpreter','latex','fontsize',fontsize);
axis tight






