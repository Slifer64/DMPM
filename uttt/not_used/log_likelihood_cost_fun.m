function J = log_likelihood_cost_fun(Data,Priors,Mu,Sigma)

nData = size(Data,2);
K = length(Priors);
d = size(Data,1)/2;

for k=1:K
    tmp = Data' - repmat(Mu(:,k)',nData,1);
    prob = sum((tmp/Sigma(:,:,k)).*tmp, 2);
    Pxi(:,k) = exp(-0.5*prob) / sqrt((2*pi)^(2*d) * (abs(det(Sigma(:,:,k)))+realmin));
end
Pxi(Pxi==0) = realmin;

J = -sum(log(Pxi*Priors))/nData;

end

