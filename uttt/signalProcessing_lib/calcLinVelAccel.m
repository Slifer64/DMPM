function [Pos, Vel, Accel] = calcLinVelAccel(data, time, varargin)
%% calculates the linear velocity and acceleration
%  @param[in] data: D x N matrix with input data, where D is the number of dimensions and N the number of data points.
%  @param[in] time: 1 x N vector of timestamps or scalar value denoting the sampling time.
%  @param[in] varargin: Variable arguments (Name-Value pairs). See function 'calculateDerivatives' for more details.
%

outArgs = calculateDerivatives(data, time, 2, varargin{:});
Pos = outArgs{1};
Vel = outArgs{2};
Accel = outArgs{3};

end

