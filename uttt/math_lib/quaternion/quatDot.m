function Qdot = quatDot(Q, v_rot)
%  quatDot Calculate the derivative of quaternion Q
%   Qdot = quatDot(Q, v_rot) calculates the quaternion derivative, Qdot, of
%   Q, given the rotational velocity, v_rot, expressed in a frame different
%   from the body frame.
    
    n = Q(1);
    e = Q(2:4);
    
    Qdot = 0.5 * [-v_rot'*e; n*v_rot + vec2ssMat(v_rot)*e];

end

function ssMat = vec2ssMat(p)

ssMat(1,1) = 0;
ssMat(2,2) = 0;
ssMat(3,3) = 0;
ssMat(1,2) = -p(3);
ssMat(2,1) = p(3);
ssMat(1,3) = p(2);
ssMat(3,1) = -p(2);
ssMat(3,2) = p(1);
ssMat(2,3) = -p(1);

end