function q = get_simple_BarrettHand_joint_values(clientID, vrep, BarrettHand, joints_indices)

    q = zeros(length(joints_indices),1);
    for i=1:length(joints_indices)
        [err_code, q(i)] = vrep.simxGetJointPosition(clientID,BarrettHand.fingers(joints_indices(i)),vrep.simx_opmode_buffer);
        if (err_code), warning('Error getting BarrettHand joint %d\nError message: %s\n',joints_indices(i), get_vrep_error_code_string(err_code)); end
    end

end