function d = normalizedSquaredNormEuclideanDistance(v, u, e)

if (nargin < 3), e=eps; end

%d =  0.5 * norm( (v-mean(v)) - (u-mean(u)))^2 / ( norm(v-mean(v))^2 + norm(u-mean(u))^2 + e);
d =  0.5 * norm( (v-mean(0)) - (u-mean(0)))^2 / ( norm(v-mean(0))^2 + norm(u-mean(0))^2 + e);

end



