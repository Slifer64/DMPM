function euler_ang = rotm2eulXYZ(rotm)
% This function takes as input 'rotm' which is a 3x3 array represanting a
% rotation matrix, and outputs the euler angles [á â ã] in rads, in the
% format XYZ. That is rotm = Rx(a)*Ry(â)*Rz(ã)
%   NOTE: Euler angles returned will be in the following ranges:
%   á --> (-pi, pi) 
%   â --> (-pi/2, pi/2)
%   ã --> (-pi, pi) 
% Angles within these ranges will be the same after decomposition: angles 
% outside these ranges will produce the correct rotation matrix, but the 
% decomposed values will be different to the input angles.

euler_ang = zeros(1,3);
euler_ang(1) = atan2(rotm(3,2),rotm(3,3));
euler_ang(2) = atan2(-rotm(3,1), (sqrt((rotm(3,2)^2)+(rotm(3,3)^2))));
euler_ang(3) = atan2(rotm(2,1),rotm(1,1));

end





