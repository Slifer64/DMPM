%% Sets the standard deviations for the kernel functions  of the DMP
%  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
%  @param[in] dmp: The DMP object.
%  @param[in] s: Scales the variance of each kernel by 's' (optional, default = 1.0).
function DMP_setStds(dmp, s)

    if (nargin < 2), s=1.0; end

    dmp.h = 1./(s*(dmp.c(2:end)-dmp.c(1:end-1))).^2;
    dmp.h = [dmp.h; dmp.h(end)];

end