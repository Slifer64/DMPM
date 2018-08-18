function [Data, index] = preprocess_demos(demos,time,tol_cutting)
%
% This function preprocess raw data and put them in a format suitable for
% SEDS. The function computes the first time derivative of demonstrations,
% shift the final point of all demonstrations to the origin (this only
% simplify computation load in SEDS), and trim datas. The function can be
% called using: 
%
%          [Data, index] = preprocess_demos(demos,time,tol_cutting)
%
% Inputs -----------------------------------------------------------------
%
%
%   o demos:   A variable containing all demonstrations (only
%              trajectories). The variable 'demos' should follow the
%              following format:
%              - demos{n}: d x T^n matrix representing the d dimensional
%                          trajectories. T^n is the number of datapoint in
%                          this demonstration (1 < n < N)
%
%   o time:    This variable can be provided in two ways. If time steps
%              between all demonstrations are the same, 'time' could be
%              given as a positive scalar (i.e. time = dt). If not, 'time'
%              should follow the following format:
%              - time{n}: 1 x T^n vector representing the time array of length
%                         T^n corresponding to the first demo  (1 < n < N)
%
%   o tol_cutting:  A small positive scalar that is used to trim data. It
%                   removes the redundant datapoint from the beginning and
%                   the end of each demonstration that their first time
%                   derivative is less than 'tol_cutting'. Though this is
%                   not necessary for SEDS; however from practical point of
%                   view, it is very useful. There are always lots of noisy
%                   data at the beginning (before the user starts the
%                   demonstration) and the end (after the user finished the
%                   demonstration) of each demonstration that are not
%                   useful.
%
% Outputs ----------------------------------------------------------------
%
%   o Data:    A 2d x N_Total matrix containing all demonstration data points.
%              Rows 1:d corresponds to trajectories and the rows d+1:2d
%              are their first time derivatives. Each column of Data stands
%              for a datapoint. All demonstrations are put next to each other 
%              along the second dimension. For example, if we have 3 demos
%              D1, D2, and D3, then the matrix Data is:
%                               Data = [[D1] [D2] [D3]]
%
%   o index:   A vector of N+1 components defining the initial index of each
%              demonstration. For example, index = [1 T1 T2 T3] indicates
%              that columns 1:T1-1 belongs to the first demonstration,
%              T1:T2-1 -> 2nd demonstration, and T2:T3-1 -> 3rd
%              demonstration.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Copyright (c) 2010 S. Mohammad Khansari-Zadeh, LASA Lab, EPFL,   %%%
%%%          CH-1015 Lausanne, Switzerland, http://lasa.epfl.ch         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The program is free for non-commercial academic use. Please contact the
% author if you are interested in using the software for commercial purposes.
% The software must not be modified or distributed without prior permission
% of the authors. Please acknowledge the authors in any academic publications
% that have made use of this code or part of it. Please use this BibTex
% reference:
% 
% S. M. Khansari-Zadeh and A. Billard, "Learning Stable Non-Linear Dynamical 
% Systems with Gaussian Mixture Models", IEEE Transaction on Robotics, 2011.
%
% To get latest upadate of the software please visit
%                          http://lasa.epfl.ch/khansari
%
% Please send your feedbacks or questions to:
%                           mohammad.khansari_at_epfl.ch

%%
%checking if a fixed time step is provided or not.
if length(time)==1
    dt = time;
end

d = size(demos{1},1); %dimensionality of demosntrations
Data=[];
index = 1;
for i=1:length(demos)
    clear tmp tmp_d
    
    % de-noising data (not necessary)
    for j=1:d
        tmp(j,:) = smooth(demos{i}(j,:),25); 
    end
    
    % some time steps may be the same
    for j=1:length(time{i})-1
        if (time{i}(j)==time{i}(j+1))
            time{i}(j+1)= (time{i}(j)+time{i}(j+2))/2;
        end
    end
%     i
%     find(~diff(time{i}))
%     pause
        
    % computing the first time derivative
%     if length(time)==1
%         tmp_d = diff(tmp,1,2)/dt;
%     else
%         tmp_d = diff(tmp,1,2)./repmat(diff(time{i}),d,1);
%     end
    tmp_d = diff(tmp,1,2);
    %tmp_d(4:6,:) = (tmp_d(4:6,:)/(pi)) * pi/2;
    tmp_d(1:3,:) = (tmp_d(1:3,:)./repmat(sqrt(sum(tmp_d(1:3,:).*tmp_d(1:3,:),1)),3,1))*0.5;
    
    % trimming demonstrations
    ind = find(sqrt(sum(tmp_d.*tmp_d,1))>tol_cutting);
    tmp = tmp(:,min(ind):max(ind)+1);
    tmp_d = tmp_d(:,min(ind):max(ind));
    time{i} = time{i}(min(ind):max(ind)+1) - time{i}(min(ind));
    
    %saving the final point (target) of each demo
    xT(:,i) = demos{i}(:,end);
    
    %[demos{i}(:,end-1) demos{i}(:,end)]
    
    % shifting demos to the origin
    tmp = tmp - repmat(xT(:,i),1,size(tmp,2));
    
    % saving demos next to each other
	% The diff function will return N-1 velocity datapoints.
	% So we add as the final velocity datapoint a zero d-dimensional vector.
	% Also, because all demostrations are shifted to the origin, the final datapoint
	% (including position and velocity) of each demonstration, will be a 2d zero vector.
    Data = [Data [tmp; tmp_d zeros(d,1)]];
    index = [index size(Data,2)+1];
end

end