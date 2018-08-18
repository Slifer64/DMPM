% Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
% Signal Analysis and Machine Perception Laboratory,
% Department of Electrical, Computer, and Systems Engineering,
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

% dynamic time warping of two signals

function [d, ind_s, ind_t, C] = my_dtw(s, t, w, dist_fun_h)
% s: signal 1, size is ns*k, row for time, column for channel 
% t: signal 2, size is nt*k, row for time, column for channel 
% w: window parameter
%      if s(i) is matched with t(j) then |i-j|<=w
% d: resulting distance

if nargin<4
    dist_fun_handle = @get_distance;
end


if nargin<3
    w=Inf;
end

if nargin==4
    dist_fun_handle=dist_fun_h;
end

ns=size(s,2);
nt=size(t,2);
if size(s,1)~=size(t,1)
    error('Error in dtw(): the dimensions of the two input signals do not match.');
end
w=max(w, abs(ns-nt)); % adapt window size

%% initialization
D=zeros(ns+1,nt+1)+Inf; % cache matrix
D(1,1)=0;

%% *** begin dynamic programming ***

%% calculate distance
for i=1:ns
    for j=max(i-w,1):min(i+w,nt)
        cost=dist_fun_handle(s(:,i),t(:,j));
        D(i+1,j+1)=cost+min( [D(i,j+1), D(i+1,j), D(i,j)] );
        
    end
end
d=D(ns+1,nt+1);


%% find the matched indices

i = ns;
j = nt;

ind_s = [];
ind_t = [];
C = [];

while (i>0 && j>0)
    cost = dist_fun_handle(s(:,i),t(:,j));
    
    ind_s = [ind_s i];
    ind_t = [ind_t j];
    C = [C cost];

    if D(i+1,j+1) == D(i,j)+cost
        i = i-1;
        j = j-1;
    elseif D(i+1,j+1) == D(i,j+1)+cost
        i = i-1;
    else
        j = j-1;
    end
end

if (i == 0)
   ind_s = [ind_s repmat(ind_s(end),1,j)]; 
   ind_t = [ind_t (j:-1:1)];
elseif (j == 0)
    ind_t = [ind_t repmat(ind_t(end),1,i)]; 
    ind_s = [ind_s (i:-1:1)];
end

ind_s = fliplr(ind_s);
ind_t = fliplr(ind_t);
C = fliplr(C);

end



function dist = get_distance(x1,x2)
    dist = norm(x1-x2);
end



