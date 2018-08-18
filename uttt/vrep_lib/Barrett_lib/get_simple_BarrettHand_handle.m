function BarrettHand = get_simple_BarrettHand_handle(clientID, vrep, Bhand_id)
    
    BarrettHand = struct('fingers',zeros(3,1));
    
    ind = [3 2 1];
    % get handles to the joints of the BarretHand fingers
    for i=1:3
        finger_name = ['BarrettHand_joint_' num2str(ind(i)) Bhand_id];
        [err_code, BarrettHand.fingers(i)]=vrep.simxGetObjectHandle(clientID,finger_name,vrep.simx_opmode_blocking);
        if (err_code), error('Error getting Barretthand finger handle %s\nError message: %s\n',finger_name, get_vrep_error_code_string(err_code)); end
    end
    
end
