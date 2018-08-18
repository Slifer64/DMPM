%% function Make signals to have the same length
%  Makes the signals the same length by recomputing their values at specific timestamps
%  using linear interpolation.
%  @param[in] Time1: 1 x N vector with the timestamps of the first signal.
%  @param[in] y1: 1 x N vector with the values of the first signal.
%  @param[in] Time2: 1 x N vector with the timestamps of the second signal.
%  @param[in] y2: 1 x N vector with the values of the second signal.
%  @param[in] Timeq: 1 x N vector with the timestamps of the returned signals.
%  @param[out] z1: 1 x N vector with the values of the first signal computed at timestamps 'Timeq'.
%  @param[out] z2: 1 x N vector with the values of the second signal computed at timestamps 'Timeq'.
function [z1, z2] = makeSignalsEqualLength(Time1, y1, Time2, y2, Timeq, varargin)

z1 = interp1(Time1, y1, Timeq, 'linear', y1(end));
z2 = interp1(Time2, y2, Timeq, 'linear', y2(end));

end
