clc;
close all;
clear;

set_matlab_utils_path();

load('data/dmp_data.mat', 'DMP_data');

N = length(DMP_data);
D = length(DMP_data{1});

DMP_w = cell(D,1);

for d=1:D
    
    DMP_w{d} = [];
    
    for n=1:N
        DMP_w{d} = [DMP_w{d} DMP_data{n}{d}.w];
    end
    
end

K = 3; % number of MPs

DMPM = cell(D,1);

for d=1:D
    
    disp(['=== Training DMPM ' num2str(d) ' ===']);
    
    w_data = DMP_w{d};
    
    disp('Running K-means...');
    [Priors0, Mu0, Sigma0] = EM_init_kmeans(w_data, K);
    
    Priors0 = ones(1,3)*1.0/K;
    
    W1 = w_data(:,1:4);
    W2 = w_data(:,5:8);
    W3 = w_data(:,9:12);
    
    Mu0(:,1) = sum(W1,2)/4;
    Mu0(:,2) = sum(W2,2)/4;
    Mu0(:,3) = sum(W3,2)/4;
    
    Sigma0 = zeros(size(Sigma0));
    for i=1:3
%         s = W1-repmat(Mu0(:,i),1,4);
%         Sigma0(:,:,i) = 0.25 * (s * s'); 
        Sigma0(:,:,i) = 10*eye(size(Sigma0(:,:,i))); 
    end
    
%     disp('Running EM...');
%     [Priors, Mu, Sigma] = EM(w_data, Priors0, Mu0, Sigma0);
    
    Priors = Priors0;
    Mu = Mu0;
    Sigma = Sigma0;
    
    dmp = DMP_data{1}{d};
    dmp.w = zeros(size(dmp.w));
    
    DMPM{d} = struct('dmp',dmp, 'Priors',Priors, 'Mu',Mu, 'Sigma',Sigma);
    
    disp('SUCCESS!');
    
    colors = {[0.75 0.75 0], [0.75 0 0.75], [0 0.75 0.75], [0 0 1], [0 0.5 0], [1 0.84 0], ...
    [0 0.45 0.74], [0.85 0.33 0.1], [1 0 0], [0.6 0.2 0], [1 0.6 0.78], [0.49 0.18 0.56]};
    legend_labels = {};

    figure('NumberTitle', 'off', 'Name', ['Dim ' num2str(d)]);
    hold on;
    for i=1:K
        bar(Mu(:,i), 'BarWidth',1.0/i, 'FaceColor',colors{mod(i-1,length(colors))+1});
        legend_labels = [legend_labels, {['Mu ' num2str(i)]} ];
    end
    for i=1:N
        bar(w_data(:,i), 'BarWidth',1.0/(K+i), 'FaceColor',colors{mod(K+i-1,length(colors))+1});
        legend_labels = [legend_labels, {['Demo ' num2str(i)]} ];
    end
    legend(legend_labels, 'interpreter','latex', 'fontsize',14);
    hold off;
    
end

save('data/DMPM.mat', 'DMPM');
