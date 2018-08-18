function axang = quat2axang(q)

axang = zeros(size(q));

for i=1:size(q,1)

    qw = q(i,1);
    qx = q(i,2);
    qy = q(i,3);
    qz = q(i,4);
    
    if (abs(qw-1) < 1e-16) 
        angle = 0;
        x = 0;
        y = 0;
        z = 1;
    else
        angle = 2 * acos(qw);
        x = qx / sqrt(1-qw*qw);
        y = qy / sqrt(1-qw*qw);
        z = qz / sqrt(1-qw*qw);
    end
    
    axang(i,:) = [x y z angle];
end


end

