% This is a matlab script illustrating how to use SEDS_lib to learn
% an arbitrary model from a set of demonstrations.
%%
% To run this demo you need to provide the variable demos composed of all
% demosntration trajectories. To get more detailed information about the
% structure of the variable 'demo', type 'doc preprocess_demos' in the
% MATLAB command window

function SEDS_selective_learning()

clc;
close all;
clear;
format compact;

%% Putting GMR and SEDS library in the MATLAB Path
set_path();


%% User Parameters and Setting

% Training parameters
load learning_params.mat K options train_Data train_index Priors Mu Sigma;

train_ind = [1, 4, 5, 7, 11, 17, 20];
Data = [];
for k=1:length(train_ind)
   i = train_ind(k);
   Data = [Data train_Data(:,train_index(i):train_index(i)-1)];
end
train_Data = Data;

%% SEDS learning algorithm
[Priors, Mu, Sigma] = SEDS_Solver(Priors,Mu,Sigma,train_Data,options); %running SEDS optimization solver

total_iters = options.max_iter;
save('selective_learning_params.mat', 'K', 'options','train_Data','train_index','Priors','Mu','Sigma','total_iters');



end







