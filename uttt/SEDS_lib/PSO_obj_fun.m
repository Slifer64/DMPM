function [J, dJ]=PSO_obj_fun(p,Data,d,K,options)
% This function computes the derivative of the likelihood objective function
% w.r.t. optimization parameters.

nData = size(Data,2);
[Priors Mu Sigma A L] = shape_DS(p,d,K,options.tol_mat_bias);

for k=1:K
    tmp = Data' - repmat(Mu(:,k)',nData,1);
    prob = sum((tmp/Sigma(:,:,k)).*tmp, 2);
    Pxi(:,k) = exp(-0.5*prob) / sqrt((2*pi)^(2*d) * (abs(det(Sigma(:,:,k)))+realmin));
end
Pxi(Pxi==0) = realmin;

% computing dJ
dJ = zeros(size(p));
rSrs = zeros(2*d,2*d);
for k=1:K
    % Sensitivity of Obj w.r.t. Priors^k
    if options.perior_opt
        dJ(k) = -exp(-p(k))*Priors(k)^2*sum(Pxi(:,k)./(Pxi*Priors) -  1);
    end
    
    % Sensitivity of Obj w.r.t. Mu
    if options.mu_opt
        tmp = Sigma(:,:,k)\(Data - repmat(Mu(:,k),1,nData));
        dJ(K+(k-1)*d+1:K+k*d) = -[eye(d);A(:,:,k)]'*tmp*(Pxi(:,k)./(Pxi*Priors))*Priors(k);
    end
    
    % Sensitivity of Obj w.r.t. Sigma
    i_c=0;
    invSigma = eye(2*d)/Sigma(:,:,k);
    invSigma_x = eye(d)/Sigma(1:d,1:d,k);
    det_term = sign(det(Sigma(:,:,k)));
    tmp = Data' - repmat(Mu(:,k)',nData,1);
    for i=1:2*d
        for j=i:2*d
            i_c = i_c + 1;
            if options.sigma_x_opt || (i<=d && j>d)
                rSrs = rSrs *0;
                rSrs(j,i)=1;
                rSrs = rSrs*L(:,:,k)' + L(:,:,k)*rSrs';
            
                rArs = (-A(:,:,k) * rSrs(1:d,1:d) + rSrs(d+1:2*d,1:d)) ...
                       *invSigma_x * Mu(1:d,k);
                
                dJ(K+K*d+(k-1)*d*(2*d+1)+i_c) = dJ(K+K*d+(k-1)*d*(2*d+1)+i_c) ...
                    -( 0.5*sum(tmp*(invSigma*rSrs*invSigma).*tmp,2) + ...
                    -0.5*det_term*trace(invSigma*rSrs) + ... %derivative with respect to det Sigma which is in the numenator
                    (tmp*invSigma)*[zeros(d,1);rArs])' ... %since Mu_xi_d = A*Mu_xi, thus we should consider its effect here
                    *(Pxi(:,k)./(Pxi(:,:)*Priors))*Priors(k);
            end
        end
    end
end
% if isinf(options.cons_penalty)
%     J = -sum(log(Pxi*Priors))/nData;
%     dJ = dJ/nData;
% else
	%Computing the penalty for violating the constraints
    %[c, tmp, dc]=options.ctr_handle(p);
    [c, tmp, dc]=ctr_principal_minor(p,d,K,options);
    J = -sum(log(Pxi*Priors))/nData + options.cons_penalty*(c'*c);
    dJ = dJ(:)/nData + 2*options.cons_penalty*(dc*c);
% end

end