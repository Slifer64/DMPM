function selective_reoptimize_SEDS()


clc;
close all;
clear;
format compact;

%% User Parameters and Setting

load selective_learning_params.mat K options train_Data train_index train_demos Priors Mu Sigma total_iters;

options.max_iter = 50;
total_iters = total_iters + options.max_iter;

set_path();


%% SEDS learning algorithm
[Priors, Mu, Sigma] = SEDS_Solver(Priors,Mu,Sigma,train_Data,options); %running SEDS optimization solver

save selective_learning_params.mat K options train_Data train_index train_demos Priors Mu Sigma total_iters;


end

