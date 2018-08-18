%% Test the quaternion product
%% Compares the output of 'quatProd' with matlab's build in function quatmultiply

clc;
close all;
clear;


i_max = 200000;
e_tol = 1e-14;

disp('Testing quatProd:');

print_step = floor(i_max/20);

for i=1:i_max
    
    if (mod(i,print_step)==0)
        disp(' ')
        fprintf('Progress %.2f%% ...',i/i_max*100);
    end
    
    q1 = rand(4,1);
    q2 = rand(4,1);

    q1 = q1/norm(q1);
    q2 = q2/norm(q2);

    q12 = quatProd(q1,q2);
    Q12 = quatmultiply(q1',q2');

    e = norm(q12(:)-Q12(:));
    
    if (e > e_tol)
        fprintf('FAILED!\n');
        q1
        q2
        q12
        Q12
        e
        return;
    end 
end

disp(' ')
fprintf('\nSUCCESS!\n');

