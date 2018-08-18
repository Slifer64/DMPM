clc;
close all;
clear;

q = rand(7,1);
dq = rand(7,1);

dt = 1e-5;

q2 = q + dq*dt;

J_dot_approx = (lwr4_jacob(q2) - lwr4_jacob(q)) / dt;

J_dot = lwr4_jacob_dot(q,dq);

norm(J_dot(:)-J_dot_approx(:))
[norm(J_dot(:)), norm(J_dot_approx(:))]

J_err = norm(J_dot(:)-J_dot_approx(:)) / min([norm(J_dot(:)), norm(J_dot_approx(:))])

