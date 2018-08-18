function BarrettHand = get_BarrettHand_handle(clientID, vrep, Bhand_id)

    % BarretHand_finger1: the one finger that is alone in the one side of the BarretHand
    % BarretHand_finger2,3: the two fingers one the other side of the BarretHand
    
    BarrettHand = struct('fingers',zeros(3,1), 'half_fingers', zeros(3,1), 'rot_fingers', zeros(2,1));
    
    % get handles to the joints of the BarretHand fingers
    [res, BarrettHand.fingers(1)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointB_0' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    [res, BarrettHand.fingers(2)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointB_2' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    [res, BarrettHand.fingers(3)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointB_1' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    
    % get handles to the joints on the midlle of the BarretHand fingers
    [res, BarrettHand.half_fingers(1)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointC_0' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    [res, BarrettHand.half_fingers(2)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointC_2' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    [res, BarrettHand.half_fingers(3)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointC_1' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    
    [res, BarrettHand.rot_fingers(1)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointA_0' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    [res, BarretttHand.rot_fingers(2)]=vrep.simxGetObjectHandle(clientID,['BarrettHand_jointA_2' Bhand_id],vrep.simx_opmode_blocking);
    if (res), error('Error getting handle! Return code: %d',res), end
    
end