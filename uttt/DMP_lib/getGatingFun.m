function gatingFunPtr = getGatingFun(GATTING_FUN_TYPE, u0, u_end)

%% ========================================================
%% Init shape attractor gating function
if (strcmpi(GATTING_FUN_TYPE,'lin'))
    gatingFunPtr = LinGatingFunction();
elseif (strcmpi(GATTING_FUN_TYPE,'exp'))
    gatingFunPtr = ExpGatingFunction();
elseif (strcmpi(GATTING_FUN_TYPE,'sigmoid'))
    gatingFunPtr = SigmoidGatingFunction();
elseif (strcmpi(GATTING_FUN_TYPE,'spring-damper'))
    gatingFunPtr = SpringDamperGatingFunction();
elseif (strcmpi(GATTING_FUN_TYPE,'constant'))
    gatingFunPtr = ConstGatingFunction();
else
    error('Unsupported gating function type ''%s''', GATTING_FUN_TYPE);
end
gatingFunPtr.init(u0, u_end);

% % Optionally, one can set the steepness of the sigmoid, but in this case 'init' must be called again
% if (strcmpi(GATTING_FUN_TYPE.GOAL_ATTR_GATTING_TYPE,'sigmoid'))
%     gatingFunPtr.a_u = 500;
% end


