function objectHandle = get_object_handle(clientID,vrep,obj_id)
    
    [err_code, visionSensorHandle]=vrep.simxGetObjectHandle(clientID, obj_id, vrep.simx_opmode_blocking);
    if (err_code), error('Error getting %s handle! Err_msg: %s', obj_id, get_vrep_error_code_string(err_code)), end

end