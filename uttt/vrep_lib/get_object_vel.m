function V = get_object_vel(clientID, vrep, objH)
% WARNING: assumes streaming of the requested data is already enabled

    V_lin = get_object_lin_vel(clientID, vrep, objH);
    
    V_rot = get_object_rot_vel(clientID, vrep, objH);

    V = [V_lin V_rot]';
end