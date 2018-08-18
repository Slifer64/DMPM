function initialize_LBR4p(vrep, clientID, LBR4p_arm, arm_world_pos, arm_world_orient, arm_joints, arm_hand_joints)

    set_object_pos_orient(vrep, clientID, LBR4p_arm.body, arm_world_pos, arm_world_orient);
    
    set_LBR4p_joint_values(clientID, vrep, LBR4p_arm, arm_joints, 1:7);
    set_LBR4p_joint_velocities(clientID, vrep, LBR4p_arm, zeros(7,1), 1:7);
    
    set_simple_BarrettHand_joint_values(clientID, vrep, LBR4p_arm.BarrettHand, arm_hand_joints, 1:3);
    set_simple_BarrettHand_joint_velocities(clientID, vrep, LBR4p_arm.BarrettHand, zeros(3,1), 1:3);

end
