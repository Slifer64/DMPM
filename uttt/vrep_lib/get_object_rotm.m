function rotm = get_object_rotm(clientID, vrep, objH, rel_to_objH)
% WARNING: assumes streaming of the requested data is already enabled

    euler_ang = get_object_eulXYZ(clientID, vrep, objH, rel_to_objH);
    rotm = eulXYZ2rotm(euler_ang);

end