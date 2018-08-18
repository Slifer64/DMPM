function [data_pos, data_axisAngle] = convertVar2Data(X)

n_frames = size(X,2);

data_pos = X(1:3,:);
Q = X(4:7,:);

data_axisAngle = zeros(4,n_frames);
for k=1:n_frames    
    data_axisAngle(:,k) = quat2axang(Q(:,k)')';
    if (any(isnan(data_axisAngle(:,k))))
        data_axisAngle(:,k) = [0 0 1 0]';
    end
end

end

