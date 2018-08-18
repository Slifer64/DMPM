% This is a matlab script illustrating how to use SEDS_lib to learn
% an arbitrary model from a set of demonstrations.
%%
% To run this demo you need to provide the variable demos composed of all
% demosntration trajectories. To get more detailed information about the
% structure of the variable 'demo', type 'doc preprocess_demos' in the
% MATLAB command window

clc;
close all;
clear;
format compact;

%% User Parameters and Setting

load learning_params.mat K options train_Data train_index train_demos Priors Mu Sigma total_iters;

options.max_iter = 500;
total_iters = total_iters + options.max_iter;

%% Putting GMR and SEDS library in the MATLAB Path
set_matlab_path();


%% SEDS learning algorithm
[Priors, Mu, Sigma] = SEDS_Solver(Priors,Mu,Sigma,train_Data,options); %running SEDS optimization solver

save learning_params.mat K options train_Data train_index train_demos Priors Mu Sigma total_iters;

%% Save SEDS parameters
if (~export2SEDS_Cpp_lib('SEDS_params.txt',Priors,Mu,Sigma))
    error('Could not write SEDS parameters...\n');
end