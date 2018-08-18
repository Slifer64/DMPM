function ssMat = vector2ssMatrix(p)

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
