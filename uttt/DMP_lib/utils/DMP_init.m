%% Initializes the DMP
%  @param[in] dmp: The DMP object.
%  @param[in] N_kernels: the number of kernels
%  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
%  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
%  @param[in] canClockPtr: Pointer to a DMP canonical system object.
%  @param[in] shapeAttrGatingPtr: Pointer to gating function for the shape attractor.
%  @param[in] goalAttrGatingPtr: Pointer to gating function for the goal attractor.
%  @param[in] kernelStdScaling: Scales the std of each kernel (optional, default = 1.0).
%  @param[in] extraArgName: Names of extra arguments.
%  @param[in] extraArgValue: Values of extra arguemnts.
function DMP_init(dmp, N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue)

    dmp.zero_tol = 1e-30;%realmin;

    if (nargin < 8), kernelStdScaling = 1.0; end

    dmp.shapeAttrGatingPtr = shapeAttrGatingPtr;
    dmp.goalAttrGatingPtr = goalAttrGatingPtr;

    dmp.N_kernels = N_kernels;
    dmp.a_z = a_z;
    dmp.b_z = b_z;
    dmp.canClockPtr = canClockPtr;

    dmp.parseExtraArgs(extraArgName, extraArgValue);

%     tau = dmp.getTau();
%     if (tau > 1)
%       dmp.a_s = 1 / (dmp.canClockPtr.tau^2);
%     else
%       dmp.a_s = (dmp.canClockPtr.tau^2);
%     end
% 	dmp.a_s = 1.0/10;
    dmp.a_s = 1.0/canClockPtr.getTau();

    dmp.w = zeros(dmp.N_kernels,1); %rand(dmp.N_kernels,1);
    dmp.setCenters();
    dmp.setStds(kernelStdScaling);

    trainParamsName = {'lambda', 'P_cov'};
    trainParamsValue = {0.99, 1e6};
    dmp.setTrainingParams('LWR', trainParamsName, trainParamsValue);

end
