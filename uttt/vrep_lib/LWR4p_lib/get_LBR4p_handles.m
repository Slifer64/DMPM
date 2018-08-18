function LBR4p_arm = get_LBR4p_handles(clientID, vrep, LBR4p_arm_id)

    LBR4p_arm = struct('joints',zeros(7,1));
    for i=1:7   
        joint_name = ['LBR4p_joint' num2str(i) LBR4p_arm_id];
        [err_code,LBR4p_arm.joints(i)]=vrep.simxGetObjectHandle(clientID,joint_name,vrep.simx_opmode_blocking);
        if (err_code), error('Error getting LBR4p joint %s\nError message: %s\n',joint_name, get_vrep_error_code_string(err_code)); end
    end
    
    arm_name = ['LBR4p' LBR4p_arm_id];
    [err_code, armHandle] = vrep.simxGetObjectHandle(clientID, arm_name, vrep.simx_opmode_blocking);
    if (err_code), error('Error getting %s handle! Err_msg: %s',arm_name, get_vrep_error_code_string(err_code)), end
    LBR4p_arm.armHandle = armHandle;
    
    body_name = ['LBR4p_body' LBR4p_arm_id];
    [err_code, LBR4p_body]=vrep.simxGetObjectHandle(clientID,body_name,vrep.simx_opmode_blocking);
    if (err_code), error('Error getting %s\nError message: %s\n',body_name, get_vrep_error_code_string(err_code)); end
    LBR4p_arm.body = LBR4p_body;
end
