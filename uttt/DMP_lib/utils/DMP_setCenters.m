%% Sets the centers for the kernel functions of the DMP according to the canonical system
%  @param[in] dmp: The DMP object.
function DMP_setCenters(dmp)

    t = ((1:dmp.N_kernels)-1)/(dmp.N_kernels-1);
    x = dmp.phase(t*dmp.getTau());
    dmp.c = x(1,:)';

end