function T = pos_quat_to_transform(pos_quat)
	T = eye(4);
	T(1:3,4) = pos_quat(1:3);
	T(1:3,1:3) = quat2rotm(pos_quat(4:7)');
end