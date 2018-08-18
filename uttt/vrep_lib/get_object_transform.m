function T = get_object_transform(clientID, vrep, objH, rel_to_objH)
% WARNING: assumes streaming of the requested data is already enabled

    pos = get_object_pos(clientID, vrep, objH, rel_to_objH); 
    rotm = get_object_rotm(clientID, vrep, objH, rel_to_objH);

    T = [rotm pos; [0 0 0 1]];

end