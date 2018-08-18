function V_rot = get_object_rot_vel(clientID, vrep, objH)
% WARNING: assumes streaming of the requested data is already enabled

    [err_code, V_rot] = vrep.simxGetObjectFloatParameter(clientID, objH, vrep.sim_objfloatparam_abs_rot_velocity, vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting streaming of rot-vel data. Err_msg: %s', get_vrep_error_code_string(err_code)); end

    V_rot = V_rot(:);
end