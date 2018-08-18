function Q12 = quatProd(Q1, Q2)

Q1 = Q1(:);
Q2 = Q2(:);

n1 = Q1(1);
e1 = Q1(2:4);

n2 = Q2(1);
e2 = Q2(2:4);

Q12(1) = n1*n2 - e1'*e2;
Q12(2:4) = n1*e1 + n2*e2 + cross(e1,e2);

end

