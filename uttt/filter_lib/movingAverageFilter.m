function y_filt = movingAverageFilter(y, win_n)

if (win_n == 1)
    y_filt = y;
    return;
end

if (mod(win_n,2) == 0), win_n = win_n +1; end

add_points = floor(win_n/2)-1;
n = length(y);


% y_filt = zeros(1,n+2*add_points);
% y_filt(1:add_points) = y(1);
% y_filt(add_points+1:n+add_points) = y;
% y_filt(add_points+n+1:n+2*add_points) = y(end);
y_filt = [y(1)*ones(1,add_points) y y(end)*ones(1,add_points)];

k = ceil(win_n/2);
s = sum(y_filt(1:win_n-1));
n = length(y_filt);

for i=win_n:n
    s = s + y_filt(i);
    y_k = y_filt(k);
    y_filt(k) = s/win_n;
    s = s - y_filt(i-win_n+1) - y_k + y_filt(k);
    k = k+1;
end

y_filt = y_filt(add_points+1:n-add_points);

end