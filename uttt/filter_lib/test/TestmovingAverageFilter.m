clc;
close all;
clear;

Ts = 0.001;
t = 0:Ts:2;

y = sin(0.5*t) + 0.1*rand(size(t));

win_n = 5;
smooth_times = 2;

y_filt = y;
y_filt2 = y;

tic
for k=1:smooth_times 
    y_filt = movingAverageFilter(y_filt, win_n);
end
toc

tic
for k=1:smooth_times 
    y_filt2 = smooth(y_filt2, win_n, 'moving');
end
toc

figure;
subplot(2,2,1);
hold on;
plot(y);
plot(y_filt);
legend('y','y-filt');
hold off
subplot(2,2,2);
hold on;
plot(y);
plot(y_filt2);
legend('y','y-filt2');
hold off
subplot(2,2,3);
hold on;
plot(y_filt);
plot(y_filt2);
legend('y-filt','y-filt2');
hold off
subplot(2,2,4);
hold on;
plot(y);
plot(y_filt);
plot(y_filt2);
legend('y','y-filt','y-filt2');
hold off



