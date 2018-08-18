%% Sets the high level training parameters of the DMP
%  @param[in] dmp: The DMP object.
%  @param[in] trainMethod: Method used to train the DMP weights.
%  @param[in] extraArgName: Names of extra arguments (optional, default = []).
%  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
%
%  \remark The extra argument names can be the following:
%  'lambda': Forgetting factor for recursive training methods.
%  'P_cov': Initial value of the covariance matrix for recursive training methods.
function DMP_setTrainingParams(dmp, trainMethod, extraArgName, extraArgValue)

dmp.trainMethod = trainMethod;

dmp.lambda = 0.995;
dmp.P_cov = 1e6;

for i=1:length(extraArgName)
   if (strcmp(extraArgName{i}, 'lambda'))
       dmp.lambda = extraArgValue{i};
   elseif (strcmp(extraArgName{i}, 'P_cov'))
       dmp.P_cov = extraArgValue{i};
   end
end

end
