function dpos_dquat = get_dpos_dquat(V, pos_quat)
	dpos_dquat = zeros(7,1);
	
	dpos_dquat(1:3) = V(1:3);
    
    Q = pos_quat(4:7);
    J_Q = get_J_Q_mat(Q);
	dpos_dquat(4:7) = 0.5 * J_Q * V(4:6);
end


function J_Q = get_J_Q_mat(Q)

n_Q = Q(1);
e_Q = Q(2:4);

J_Q = [ -e_Q'; (n_Q*eye(3) - vector2ssMatrix(e_Q)) ];

end

