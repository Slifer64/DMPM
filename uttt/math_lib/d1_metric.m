function d = d1_metric(p1,Q1, p2,Q2)

d_p = normalizedSquaredNormEuclideanDistance(p1, p2);

d_eo = quatDist(Q1,Q2);
% Q1 = Q1 / norm(Q1);
% Q2 = Q2 / norm(Q2);
% d_o = cosDist(Q1,Q2);

d = 0.5 * (d_p + d_eo);

end



