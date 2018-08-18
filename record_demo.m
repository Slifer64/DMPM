function record_demo()

% close all;
% clc;
% clear;

fH = figure('Name','Mouse Data', 'NumberTitle','off', 'Color','none');

ax = axes(fH);

N_demos = 12;

demo_data = cell(N_demos,1);
Time = cell(N_demos,1);

for n=1:N_demos
    
    %% Draw an abstract shape
    h = imfreehand;
    tic
    pos_data = wait(h); % double click on the line to continue
    T = toc;
    
    T

    n_points = size(pos_data,1);
    Time{n} = (0:(n_points-1))*T/(n_points-1);
    demo_data{n} = pos_data;
    
end

save('data/demos.mat','demo_data','Time');

plot_fun(ax, demo_data);

%% =====================================================================


function plot_fun(ax, plot_data)
    
    N = length(plot_data);

    for i=1:N
        x = plot_data{i}(:,1);
        y = plot_data{i}(:,2);
        
        plot(ax, x, y);
        hold on;
    end
    hold off;
end

end
