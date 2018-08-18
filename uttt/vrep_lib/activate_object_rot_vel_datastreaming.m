function activate_object_rot_vel_datastreaming(clientID, vrep, objHandle)

    [err_code, ~] = vrep.simxGetObjectFloatParameter(clientID, objHandle, vrep.sim_objfloatparam_abs_rot_velocity, vrep.simx_opmode_streaming);
    if (err_code>1), warning('Error enabling streaming of rot-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    
end