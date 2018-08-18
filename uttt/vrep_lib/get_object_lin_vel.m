function V_lin = get_object_lin_vel(clientID, vrep, objH)
% WARNING: assumes streaming of the requested data is already enabled

    [err_code, v_x] = vrep.simxGetObjectFloatParameter(clientID, objH, vrep.sim_objfloatparam_abs_x_velocity, vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting x-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    [err_code, v_y] = vrep.simxGetObjectFloatParameter(clientID, objH, vrep.sim_objfloatparam_abs_y_velocity, vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting streaming of y-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    [err_code, v_z] = vrep.simxGetObjectFloatParameter(clientID, objH, vrep.sim_objfloatparam_abs_z_velocity, vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting streaming of z-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end

    V_lin = [v_x v_y v_z]';
end