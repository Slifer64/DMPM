function d = cosDist(v, u, e)

if (nargin < 3)
	e = eps;
end
	
d = 0.5*(1 - v'*u/(norm(v)*norm(u)+e));

end

