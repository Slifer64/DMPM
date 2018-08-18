function rotm = eulXYZ2rotm(euler_ang)
% This function accepts the euler angles euler_ang = [á â ã] in rads in the 
% format XYZ and outputs the corresponding rotation matrix: 
% rotm = Rx(a)*Ry(â)*Rz(ã)

% % convert to degrees to use the matlab functions rotx, roty and rotz which
% % take in as arguments degrees of type 'double'
% euler_ang = double(euler_ang)*180/pi;
% rotm = rotx(euler_ang(1))*roty(euler_ang(2))*rotz(euler_ang(3));

x_rot = [1 0 0; 0 cos(euler_ang(1)) -sin(euler_ang(1)); 0 sin(euler_ang(1)) cos(euler_ang(1))];
y_rot = [cos(euler_ang(2)) 0 sin(euler_ang(2)); 0 1 0; -sin(euler_ang(2)) 0 cos(euler_ang(2))];
z_rot = [cos(euler_ang(3)) -sin(euler_ang(3)) 0 ; sin(euler_ang(3)) cos(euler_ang(3)) 0; 0 0 1];        
rotm = x_rot*y_rot*z_rot;

end

