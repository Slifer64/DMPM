function  set_LBR4p_joint_velocities(clientID, vrep, LBR4p_arm, joint_velocities, ind)

    for i=1:length(ind)
        err_code = vrep.simxSetJointTargetVelocity(clientID,LBR4p_arm.joints(ind(i)),joint_velocities(i),vrep.simx_opmode_oneshot);
        if (err_code>1), warning('Error setting LBR4p joint %d velocity\nError message: %s\n',ind(i), get_vrep_error_code_string(err_code)); end
    end
    
end
