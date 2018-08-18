% This is a matlab script illustrating how to use SEDS_lib to learn
% an arbitrary model from a set of demonstrations.
%%
% To run this demo you need to provide the variable demos composed of all
% demosntration trajectories. To get more detailed information about the
% structure of the variable 'demo', type 'doc preprocess_demos' in the
% MATLAB command window

function SEDS_Learning()

clc;
close all;
clear;
format compact;

%% Putting GMR and SEDS library in the MATLAB Path
set_matlab_path();

%% load demos
% load training set
load('train_demos.mat','train_demos');
train_T = train_demos(:,1);
train_Q = train_demos(:,3);
train_demos = train_demos(:,2);

[train_Data, train_index] = convert_demos_to_rawData(train_demos);


%% User Parameters and Setting

% Training parameters
K = 13; %Number of Gaussian funcitons

% A set of options that will be passed to the solver. Please type 
% 'doc preprocess_demos' in the MATLAB command window to get detailed
% information about other possible options.
options.tol_mat_bias = 10^-16; % A very small positive scalar to avoid
                               % instabilities in Gaussian kernel [default: 10^-15]
                              
options.display = 1;          % An option to control whether the algorithm
                              % displays the output of each iterations [default: true]
                              
options.tol_stopping = 10^-15;  % A small positive scalar defining the stoppping
                                % tolerance for the optimization solver [default: 10^-10]

options.max_iter = 1000;       % Maximum number of iteration for the solver [default: i_max=1000]

options.objective = 'likelihood';    % 'likelihood': use likelihood as criterion to
                              % optimize parameters of GMM
                              % 'mse': use mean square error as criterion to
                              % optimize parameters of GMM
                              % 'direction': minimize the angle between the
                              % estimations and demonstrations (the velocity part)
                              % to optimize parameters of GMM                              
                              % [default: 'mse']
                              
options.cons_penalty = Inf;

%% SEDS learning algorithm
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(train_Data,K); %finding an initial guess for GMM's parameter
[Priors, Mu, Sigma] = SEDS_Solver(Priors_0,Mu_0,Sigma_0,train_Data,options); %running SEDS optimization solver

total_iters = options.max_iter;
save('learning_params.mat', 'K', 'options','train_Data','train_index','train_demos','Priors','Mu','Sigma','total_iters');

%% Save SEDS parameters
if (~export2SEDS_Cpp_lib('SEDS_params.txt',Priors,Mu,Sigma))
    error('Could not write SEDS parameters...\n');
end


end

function [Data, index] = convert_demos_to_rawData(demos)

Data = [];
index = 1;
for i=1:length(demos)
    Data = [Data demos{i}];
    index = [index size(demos{i},2)+index(end)];
end

end

function save_init_pos(filename, demos, T)

    x0_all = zeros(3+4,length(demos));
    dlmwrite(filename, size(x0_all'),'newline','pc','Delimiter',' ','precision','%i');
    for i=1:size(x0_all,2)
        x0_all(:,i) = demos{i}(1:7,1);
        dlmwrite(filename, x0_all(:,i)','newline','pc','-append','Delimiter',' ','precision','%.14f');
        dlmwrite(filename, length(diff(T{i})),'newline','pc','-append','Delimiter',' ','precision','%i');
        dlmwrite(filename, diff(T{i}),'newline','pc','-append','Delimiter',' ','precision','%.14f');
    end

end

function [demos, T, V] = transform_data(demos, T, Q)

    V = cell(length(demos));

    for k=1:length(demos)
        demos_k = demos{k};

        P_k = demos_k(1:3,:);
        dP_k = demos_k(7:9,:);
        Q_k = Q{k};
        dQ_k = zeros(4,size(Q_k,2));
        V_k = demos_k(7:12,:);
        for i=1:size(Q_k,2)
          n_Q = Q_k(1,i);
          e_Q = Q_k(2:4,i);
          J_Q = [-e_Q'; n_Q*eye(3)-vector2ssMatrix(e_Q)];
          dQ_k(:,i) = 0.5 * J_Q * V_k(4:6,i);
        end

        V{k} = V_k;
        demos{k} = [P_k; Q_k; dP_k; dQ_k];
    end

end








