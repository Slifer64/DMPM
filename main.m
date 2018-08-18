clc;
close all;
clear;

format compact;

disp('Demo recording...');
record_demo();
disp('SUCCESS!');
pause

disp('Processing demo data...');
process_demo_data();
disp('SUCCESS!');
pause

disp('Processing data...');
process_data();
disp('SUCCESS!');
pause

disp('Training DMPs...');
train_DMPs();
disp('SUCCESS!');
pause
