function pos = get_object_pos(clientID, vrep, objH, rel_to_objH)
% WARNING: assumes streaming of the requested data is already enabled

    [err_code,pos] = vrep.simxGetObjectPosition(clientID,objH,rel_to_objH,vrep.simx_opmode_buffer);
    if (err_code>1), warning('Error getting position data.\n Err_msg: %s',get_vrep_error_code_string(err_code)); end
    pos = pos(:);

end