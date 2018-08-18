%% Returns the phase variable for the input time instant.
%  @param[in] t: The time instant.
%  @param[out] x: The phase variable for time 't'.
function x = DMP_phase(dmp, t)

x = dmp.canClockPtr.getPhase(t);

end