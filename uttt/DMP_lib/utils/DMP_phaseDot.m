%% Returns the derivative of the phase variable.
%  @param[in] x: The phase variable.
%  @param[out] dx: The derivative of the phase variable.
function dx = DMP_phaseDot(dmp, x)

dx = dmp.canClockPtr.getPhaseDot(x);

end