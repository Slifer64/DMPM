function set_simple_BarrettHand_joint_values(clientID, vrep, BarrettHand, joint_values, ind)

    for i=1:length(ind)
        err_code = vrep.simxSetJointPosition(clientID,BarrettHand.fingers(ind(i)),joint_values(i),vrep.simx_opmode_streaming);
        if (err_code>1), warning('Error setting BarrettHand joint %d position\nError message: %s\n',ind(i), get_vrep_error_code_string(err_code)); end
    end
    vrep.simxGetPingTime(clientID);

end
