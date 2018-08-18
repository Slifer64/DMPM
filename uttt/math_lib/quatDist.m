function dist = quatDist(Q1, Q2)

Qdiff = quatDiff(Q1, Q2);

dist = norm(Qdiff(2:4));

end

