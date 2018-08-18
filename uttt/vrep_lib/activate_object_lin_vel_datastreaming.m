function activate_object_lin_vel_datastreaming(clientID, vrep, objHandle)

    [err_code, ~] = vrep.simxGetObjectFloatParameter(clientID, objHandle, vrep.sim_objfloatparam_abs_x_velocity, vrep.simx_opmode_streaming);
    if (err_code>1), warning('Error enabling streaming of x-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    [err_code, ~] = vrep.simxGetObjectFloatParameter(clientID, objHandle, vrep.sim_objfloatparam_abs_y_velocity, vrep.simx_opmode_streaming);
    if (err_code>1), warning('Error enabling streaming of y-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    [err_code, ~] = vrep.simxGetObjectFloatParameter(clientID, objHandle, vrep.sim_objfloatparam_abs_z_velocity, vrep.simx_opmode_streaming);
    if (err_code>1), warning('Error enabling streaming of z-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    
end