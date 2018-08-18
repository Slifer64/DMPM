%% Sets the kernels of the DMP using the EM algorithm
function DMP_set_kernels_with_EM(dmp, Time, yd_data)

  error('Function ''set_kernels_with_EM'' is not supported yet...');

%           ts = Time(end) - Time(1);
%           
%           x = exp(-dmp.ax*Time/ts);
%           
%           Data = [x; yd_data];
%           
%           disp('EM_init_kmeans');
%           tic
%           [Priors, Mu, Sigma] = EM_init_kmeans(Data, dmp.N_kernels);
%           toc
%           
%           disp('EM');
%           tic
%           [Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);
%           toc
% 
%           dmp.c = Mu(1,:)';
%           for k=1:dmp.N_kernels
%               dmp.h(k) = 1/(2*Sigma(1,1,k));
%           end
end