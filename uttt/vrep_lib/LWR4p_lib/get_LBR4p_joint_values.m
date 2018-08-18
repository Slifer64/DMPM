function q = get_LBR4p_joint_values(clientID, vrep, LBR4p_arm, joints_indices)

    q = zeros(length(joints_indices),1);
    for i=1:length(joints_indices)
        [err_code, q(i)] = vrep.simxGetJointPosition(clientID,LBR4p_arm.joints(joints_indices(i)),vrep.simx_opmode_buffer);
        if (err_code), warning('Error getting LBR4p joint %d\nError message: %s\n',joints_indices(i), get_vrep_error_code_string(err_code)); end
    end

end

