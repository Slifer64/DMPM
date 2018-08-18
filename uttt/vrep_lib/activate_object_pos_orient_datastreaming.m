function activate_object_pos_orient_datastreaming(clientID, vrep, objHandle, rel_to_objHandle)

    activate_object_pos_datastreaming(clientID, vrep, objHandle, rel_to_objHandle);
    activate_object_orient_datastreaming(clientID, vrep, objHandle, rel_to_objHandle);
    
end