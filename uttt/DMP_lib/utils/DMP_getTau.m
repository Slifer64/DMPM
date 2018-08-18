%% Returns the time cycle of the DMP
%  @param[in] dmp: The DMP object.
%  @param[out] tau: The time cycle of the DMP.
function tau = DMP_getTau(dmp)

    tau = dmp.canClockPtr.getTau();

end