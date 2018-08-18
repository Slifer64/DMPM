function [Time1, z1, Time2, z2] = alignSignalsWithDTW(Time1, y1, Time2, y2, varargin)

if (nargin < 5)
    dist_f = @(s1,s2) norm(s1-s2);
end

dtw_win = floor(max([size(y1,2), size(y2,2)])/3);
[dtw_dist, ind_y1, ind_y2] = dtw(y1, y2, dtw_win, dist_f);

Time1 = Time1(ind_y1);
z1 = y1(:, ind_y1);

Time2 = Time2(ind_y2);
z2 = y2(:, ind_y2);

end
