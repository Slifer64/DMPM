function set_simple_BarrettHand_joint_velocities(clientID, vrep, BarrettHand, joint_velocities, ind)

    for i=1:length(ind)
        err_code = vrep.simxSetJointTargetVelocity(clientID,BarrettHand.fingers(ind(i)),joint_velocities(i),vrep.simx_opmode_oneshot);
        if (err_code>1), warning('Error setting BarrettHand joint %d velocity\nError message: %s\n',ind(i), get_vrep_error_code_string(err_code)); end
    end
    vrep.simxGetPingTime(clientID);

end