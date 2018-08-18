function set_BarrettHand_joint_values(clientID, vrep, BarrettHand, fingers_joints, half_fingers_joints, rot_fingers_joints)

    for i=1:3
        vrep.simxSetJointPosition(clientID,BarrettHand.fingers(i),fingers_joints(i),vrep.simx_opmode_oneshot);
        vrep.simxSetJointPosition(clientID,BarrettHand.half_fingers(i),half_fingers_joints(i),vrep.simx_opmode_oneshot);
    end
    
    for i=1:2
        vrep.simxSetJointPosition(clientID,BarrettHand.rot_fingers(i),rot_fingers_joints(i),vrep.simx_opmode_oneshot);
    end
    
    vrep.simxGetPingTime(clientID);

end