%% Returns a column vector with the values of the kernel functions of the DMP
%  @param[in] dmp: The DMP object.
%  @param[in] x: phase variable.
%  @param[out] Psi: column vector with the values of the kernel functions of the DMP.
function Psi = DMP_gaussianKernel(dmp,x)

    n = length(x);
    Psi = zeros(dmp.N_kernels, n);
    
    for j=1:n
        Psi(:,j) = exp(-dmp.h.*((x(j)-dmp.c).^2));
    end   

    %Psi = Psi.^7;
end