function [Quat, rotVel, rotAccel] = calcRotVelAccel(Qdata, time, varargin)
%% calculates the linear velocity and acceleration
%  @param[in] Qdata: 4 x N matrix with input data, where each column is a unit quaternion.
%  @param[in] time: 1 x N vector of timestamps or scalar value denoting the sampling time.
%  @param[in] varargin: Variable arguments (Name-Value pairs). See function 'calculateDerivatives' for more details.
%

n_data = size(Qdata,2);

if (length(time) == 1)
   time = (0:(n_data-1))*time;
end

v_rot_data = zeros(3,n_data);
for i=1:n_data-1
   v_rot_data(:,i+1) = quatLog(quatProd(Qdata(:,i+1),quatInv(Qdata(:,i)))) / (time(i+1)-time(i));
end

outArgs = calculateDerivatives(v_rot_data, time, 1, varargin{:});
rotVel = outArgs{1};
rotAccel = outArgs{2};

Quat = zeros(4,size(rotVel,2));
Quat(:,1) = Qdata(:,1);
for i=1:size(Quat,2)-1
    Quat(:,i+1) = quatProd(quatExp(rotVel(:,i)*(time(i+1)-time(i))), Quat(:,i));
end

end

