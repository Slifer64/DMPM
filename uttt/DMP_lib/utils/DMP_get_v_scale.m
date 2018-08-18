%% Returns the scaling factor of the DMP
%  @param[in] dmp: The DMP object.
%  @param[out] v_scale: The scaling factor of the DMP.
function v_scale = DMP_get_v_scale(dmp)

    v_scale = dmp.getTau() * dmp.a_s;
    
end