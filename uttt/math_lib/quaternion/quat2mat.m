function Qmat = quat2mat(Q)
%   Qmat = quat2mat(Q) returns the the matrix form of quaterion Q.
%   Given Q and Q2, Qmat*Q2 is equivalent to the quaternion product
%   of Q and Q2.

Q = Q(:);
n = Q(1);
e = Q(2:4);

Qmat = [ n           -e'          
         e   n*eye(3)+vec2ssMat(e)];

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
