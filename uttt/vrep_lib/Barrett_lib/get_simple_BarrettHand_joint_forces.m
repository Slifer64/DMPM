function f = get_simple_BarrettHand_joint_forces(clientID, vrep, BarrettHand, joints_indices)

    f = zeros(length(joints_indices),1);
    for i=1:length(joints_indices)
        [err_code, f(i)] = vrep.simxGetJointForce(clientID,BarrettHand.fingers(joints_indices(i)),vrep.simx_opmode_buffer);
        if (err_code), warning('Error getting BarrettHand joint force %d\nError message: %s\n',joints_indices(i), get_vrep_error_code_string(err_code)); end
    end

end
