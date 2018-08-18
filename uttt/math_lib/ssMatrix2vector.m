function p = ssMatrix2vector(ssMat)

p(1) = (ssMat(3,2) - ssMat(2,3))/2;
p(2) = (ssMat(1,3) - ssMat(3,1))/2;
p(3) = (ssMat(2,1) - ssMat(1,2))/2;
	
end

