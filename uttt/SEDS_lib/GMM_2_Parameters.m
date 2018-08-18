function p0 = GMM_2_Parameters(Priors,Mu,Sigma,d,K)
% transforming optimization parameters into a column vector
p0 = [Priors(:); reshape(Mu(1:d,:),[],1)];
% p0 = [log(Priors(:));reshape(Mu(1:d,:),[],1)];
for k=1:K
    Sigma(:,:,k) = chol(Sigma(:,:,k))';
    for i=1:2*d
        p0 = [p0;Sigma(i:2*d,i,k)];
    end
end

end