%% DMP constructor
%  @param[in] dmp: The DMP object.
%  @param[in] N_kernels: the number of kernels
%  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
%  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
%  @param[in] can_sysPtr: Pointer to a DMP canonical system object.
%  @param[in] std_K: Scales the std of each kernel (optional, default = 1).
function DMP_constructor(dmp, N_kernels, a_z, b_z, can_sysPtr, std_K)

if (nargin < 4)
    return;
else
    if (nargin < 5), std_K=1; end
    dmp.init(N_kernels, a_z, b_z, can_sysPtr, std_K);
end


end