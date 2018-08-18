function [Priors Mu Sigma A L] = shape_DS(p,d,K,Tol)
if K==1
    Priors = 1;
else
	Priors = p(1:K);
    Priors = Priors(:);
    %Priors = 1./(1+exp(-p(1:K)));
    Priors = Priors/sum(Priors);
end

Mu_x = reshape(p(K+1:K+d*K),d,K);

% this function form Sigma from a column vector of parameters p
L = zeros(2*d,2*d,K);
Sigma = zeros(2*d,2*d,K);
i_c = K+d*K+1;
for k=1:K
    for i=1:2*d
        L(i:2*d,i,k) = p(i_c:i_c+2*d-i);
        i_c = i_c + 2*d - i + 1;
    end
    Sigma(:,:,k) = L(:,:,k)*L(:,:,k)' + Tol;
    
    A(:,:,k) = Sigma(d+1:end,1:d,k)/Sigma(1:d,1:d,k);
    
    % Based on the second stability conditions
    Mu_xd(:,k) = A(:,:,k)*Mu_x(:,k);
end
Mu=[Mu_x;Mu_xd];

end