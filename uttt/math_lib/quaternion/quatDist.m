function dist = quatDist(Q1, Q2)
%  quatDist Calculate the distance of two quaternions.
%   dist = quatDist(Q1, Q2) calculates the distance between two quaternions
%   Q1 and Q2. The difference between Q1 and Q2 is computed and the norm
%   of the the vector part is taken as the distance.
%   Each element of Q1 and Q2 must be a real number.  
%   Additionally, Q1 and Q2 have their scalar number as the first 
%   column.

Qdiff = quatDiff(Q1, Q2);

dist = norm(Qdiff(2:4));

end

