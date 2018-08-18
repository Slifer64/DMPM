function activate_object_pos_datastreaming(clientID, vrep, objHandle, rel_to_objHandle)

    [err_code, ~] = vrep.simxGetObjectPosition(clientID,objHandle,rel_to_objHandle,vrep.simx_opmode_streaming);
    if (err_code>1), warning('Error enabling streaming of pos data. Err_msg: %s', get_vrep_error_code_string(err_code)); end
    vrep.simxGetPingTime(clientID);
    
end