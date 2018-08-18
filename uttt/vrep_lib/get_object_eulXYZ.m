function euler_ang = get_object_eulXYZ(clientID, vrep, objH, rel_to_objH)
% WARNING: assumes streaming of the requested data is already enabled

    [err_code, euler_ang] = vrep.simxGetObjectOrientation(clientID,objH,rel_to_objH,vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting orientation data.\n Err_msg: %s',get_vrep_error_code_string(err_code)); end
    
end