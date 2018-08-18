% Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
% Signal Analysis and Machine Perception Laboratory,
% Department of Electrical, Computer, and Systems Engineering,
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

% dynamic time warping of two signals

function [d, ind] = dtw(s,t,w,dist_type)
% s: signal 1, size is ns*k, row for time, colume for channel 
% t: signal 2, size is nt*k, row for time, colume for channel 
% w: window parameter
%      if s(i) is matched with t(j) then |i-j|<=w
% d: resulting distance

dist_fun_handle = @pos_dist;
if (strcmpi(dist_type,'orient'))
	dist_fun_handle = @orient_dist;
end

if nargin<3
    w=Inf;
end

ns=size(s,1);
nt=size(t,1);
if size(s,2)~=size(t,2)
    error('Error in dtw(): the dimensions of the two input signals do not match.');
end
w=max(w, abs(ns-nt)); % adapt window size

%% initialization
D=zeros(ns+1,nt+1)+Inf; % cache matrix
D(1,1)=0;

%% begin dynamic programming
for i=1:ns
    for j=max(i-w,1):min(i+w,nt)
        cost=dist_fun_handle(s(i,:),t(j,:));
        D(i+1,j+1)=cost+min( [D(i,j+1), D(i+1,j), D(i,j)] );
        
    end
end
d=D(ns+1,nt+1);

if (ns > nt)
    temp = s;
    s = t;
    t = temp;
    D = D';
    ns=size(s,1);
    nt=size(t,1);
end

C = ones(ns,1)*Inf;
ind = zeros(ns,1);
i = ns;
j = nt;

while (i>0)
    cost = dist_fun_handle(s(i,:),t(j,:));
    if (C(i) > cost)
        ind(i) = j;
        C(i) = cost;
    end
    if D(i+1,j+1) == D(i,j)+cost
        i = i-1;
        j = j-1;
    elseif D(i+1,j+1) == D(i,j+1)+cost
        i = i-1;
    else
        j = j-1;
    end
    
end

end


function dist = pos_dist(p1,p2)
	dist = norm(p1-p2);
end

function dist = orient_dist(angles1,angles2)
	R1 = calc_rotMat_from_anglesOfAxis(angles1(1),angles1(2),angles1(3));
	R2 = calc_rotMat_from_anglesOfAxis(angles2(1),angles2(2),angles2(3));
	dist = norm(eye(3,3)-R1*R2')/2;
end

