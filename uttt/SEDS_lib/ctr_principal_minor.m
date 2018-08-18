function [c ceq dc dceq]=ctr_principal_minor(p,d,K,options)
% This function computes the derivative of the constrains w.r.t.
% optimization parameters.
ceq = [];
dceq = [];
c  = zeros(K*d,1);
dc = zeros(length(p),K*d);
[tmp tmp Sigma A L] = shape_DS(p,d,K,options.tol_mat_bias);

rSrs = zeros(2*d,2*d);
for k=1:K
    invSigma_x = eye(d)/Sigma(1:d,1:d,k);
    B = A(:,:,k)+A(:,:,k)';
    for j = 1:d
        %conditions on negative definitenes of A
        if (-1)^(j+1)*det(B(1:j,1:j))+(options.tol_mat_bias)^(j/d) > 0  || isinf(options.cons_penalty)
            c((k-1)*d+j)=(-1)^(j+1)*det(B(1:j,1:j))+(options.tol_mat_bias)^(j/d);
        end
        
        %computing the sensitivity of the constraints to the parameters
        if nargout > 2
            i_c = 0;
            for i1=1:d
                for i2=i1:2*d
                    i_c = i_c +1;
                    if options.sigma_x_opt || i1>d || i2>d
                        rSrs = rSrs * 0;
                        rSrs (i2,i1) = 1;

                        rSrs = rSrs*L(:,:,k)' + L(:,:,k)*rSrs';
                        rArs = (-A(:,:,k) * rSrs(1:d,1:d) + rSrs(d+1:2*d,1:d)) * invSigma_x;
                        rBrs = rArs + rArs';
                        if j==1
                            dc((d+1)*K + (k-1)*d*(2*d+1)+i_c,(k-1)*d+j) = rBrs(1,1);
                        else
                            tmp = det(B(1:j,1:j));
                            if abs(tmp) > 1e-10
                                term = trace(B(1:j,1:j)\rBrs(1:j,1:j))*tmp;
                            else
                                term = trace(adjugate(B(1:j,1:j))*rBrs(1:j,1:j));
                            end
                            dc((d+1)*K + (k-1)*d*(2*d+1)+i_c,(k-1)*d+j) = (-1)^(j+1)*term;
                        end
                    end
                end
            end
        end
    end
end

end