function activate_object_vel_datastreaming(clientID, vrep, objHandle)

    activate_object_lin_vel_datastreaming(clientID, vrep, objHandle);
    
    activate_object_rot_vel_datastreaming(clientID, vrep, objHandle);
    
end