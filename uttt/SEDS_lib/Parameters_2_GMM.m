function [Priors Mu Sigma] = Parameters_2_GMM(popt,d,K,options)
% transforming the column of parameters into Priors, Mu, and Sigma
[Priors Mu Sigma] = shape_DS(popt,d,K,options.tol_mat_bias);
if options.normalization
    for k=1:K
        Sigma(:,:,k) = options.Wn\Sigma(:,:,k)/options.Wn;
        Mu(1:d,k) = options.Wn(1:d,1:d)\Mu(1:d,k);
        Mu(d+1:2*d,k) = Sigma(d+1:2*d,1:d,k)/Sigma(1:d,1:d,k)*Mu(1:d,k);
        Sigma(1:d,d+1:2*d,k) = Sigma(d+1:2*d,1:d,k)';
    end
end

end