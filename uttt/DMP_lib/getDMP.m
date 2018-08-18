function dmp = getDMP(DMP_TYPE, N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgNames, extraArgValues)


%% ========================================================
%% Construct DMP
if (strcmpi(DMP_TYPE,'DMP'))
    dmp = DMP();
elseif (strcmpi(DMP_TYPE,'DMP-bio'))
    dmp = DMP_bio();
elseif (strcmpi(DMP_TYPE,'DMP-plus'))
    dmp = DMP_plus();
elseif (strcmpi(DMP_TYPE,'DMP-Shannon'))
    dmp = DMP_Shannon();
else
    error('Unsupported DMP type ''%s''', DMP_TYPE);
end

dmp.init(N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgNames, extraArgValues);




end

