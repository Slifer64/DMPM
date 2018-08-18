function pos_quat = transform_to_pos_quat(T)
	pos_quat = zeros(7,1);
	pos_quat(1:3) = T(1:3,4);
	
	quat = rotm2quat(T(1:3,1:3))';
	pos_quat(4:end) = quat;
end