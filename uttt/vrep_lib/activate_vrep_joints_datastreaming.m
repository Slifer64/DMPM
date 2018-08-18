function activate_vrep_joints_datastreaming(clientID, vrep, obj_struct)
    
    field_names = fieldnames(obj_struct);
    
    for k=1:length(field_names)
        ob = getfield(obj_struct, field_names{k});
        if (isstruct(ob))
            activate_vrep_joints_datastreaming(clientID, vrep, ob);
        else
            for i=1:length(ob)        
                vrep.simxGetJointPosition(clientID,ob(i),vrep.simx_opmode_streaming);
                vrep.simxGetJointForce(clientID,ob(i),vrep.simx_opmode_streaming);
                vrep.simxGetPingTime(clientID);
            end
        end
    end
    
    vrep.simxGetPingTime(clientID);
    
end