%% Trains the DMP weights using RLWR (Recursive Locally Weighted Regression)
%  The k-th weight is set to w_k = (s'*Psi*Fd) / (s'*Psi*s), 
%  where Psi = exp(-h(k)*(x-c(k)).^2)
%  @param[in] x: Row vector with the values of the phase variable.
%  @param[in] s: Row vector with the values of the term that is multiplied by the weighted sum of Gaussians.
%  @param[in] Fd: Row vector with the desired values of the shape attractor.
function [w, P] = RLWR(Psi, s, Fd, lambda, P)

    n = length(Fd);
    N_kernels = size(Psi,1);
    dmp.w = zeros(N_kernels, 1);
    
    for i = 1:n 
      psi = Psi(:,i);
      error = Fd(i) - dmp.w*s(i);
      P = (P - (P.^2*s(i)^2) ./ (lambda./psi + P*s(i)^2)) / lambda;
      dmp.w = dmp.w + psi .* P * s(i) .* error;   
    end

end

