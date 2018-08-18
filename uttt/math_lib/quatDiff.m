function Qdiff = quatDiff(Q1, Q2)

Qdiff = quatProd(Q1, quatInv(Q2));

end