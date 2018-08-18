function [c ceq dc dceq]=ctr_eigenvalue(p,d,K,options)
% This function computes the derivative of the constrains w.r.t.
% optimization parameters.

[tmp tmp Sigma A L] = shape_DS(p,d,K,options.tol_mat_bias);
ceq = [];
dceq = [];
c  = zeros(K*d,1);
dc = zeros(length(p),K*d);
delta = 10^-5;
rSrs = zeros(2*d,2*d);

for k=1:K
    B = A(:,:,k)+A(:,:,k)';
    [V lambda] = eig(B);
    [lambda ind] = sort(diag(lambda));
    c((k-1)*d+1:k*d)=lambda;
    
    if nargout > 2
        i_c = K + d*K + (k-1)*d*(2*d+1);
        
        if all(sum((repmat(lambda,1,d) - repmat(lambda,1,d)')==0)==1) %the eigenvalue is not repeated
            V = V(:,ind);
            invSigma_x = eye(d)/Sigma(1:d,1:d,k);
            ch_direct = true;
        else
            ch_direct = false;
        end
        
        for i=1:2*d
            for j=i:2*d
                i_c = i_c + 1;
                if options.sigma_x_opt || (i<=d && j>d)
                    if ch_direct %the eigenvalue is not repeated
                        rSrs = rSrs * 0;
                        rSrs (j,i) = 1;

                        rSrs = rSrs*L(:,:,k)' + L(:,:,k)*rSrs';
                        rArs = (-A(:,:,k) * rSrs(1:d,1:d) + rSrs(d+1:2*d,1:d)) * invSigma_x;
                        rBrs = rArs + rArs';
                        for ii=1:d
                            dc(i_c,(k-1)*d+ii) = V(:,ii)'*rBrs*V(:,ii);
                        end                        
                    else %computing using finite difference
                        Ltmp = L(:,:,k);
                        Ltmp(j,i) = Ltmp(j,i) + delta;
                        Sigma_k = Ltmp*Ltmp';
                        Btmp = Sigma_k(d+1:2*d,1:d)/Sigma_k(1:d,1:d);
                        Btmp = Btmp + Btmp';
                        lambda2 = eig(Btmp);
                        lambda_d = (lambda2-lambda)/delta;
                        dc(i_c,(k-1)*d+1:k*d) = lambda_d;
                    end
                end
            end
        end
    end
end

end