function [pos, euler_ang] = get_object_pos_eulXYZ(clientID, vrep, objH, rel_to_objH)
% WARNING: assumes streaming of the requested data is already enabled

    pos = get_object_pos_eulXYZ(clientID, vrep, objH, rel_to_objH);
    euler_ang = get_object_orient_eulXYZ(clientID, vrep, objH, rel_to_objH);

end