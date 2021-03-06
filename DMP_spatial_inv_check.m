clc;
close all;
clear;

set_matlab_utils_path();

% load('data/data.mat','Data');
load('data/spatial_inv_data.mat','Data');

N = length(Data);

DMP_data = cell(N,1);

N_kernels = 40;
a_z = 16;
b_z = a_z/4;
train_method = 'LWR';
dt = 0.01;

canClockPtr = LinCanonicalClock();

Data_sim = cell(N,1);

for n=1:N
    
    data = Data{n};
%     data = Data{1};
    
    Timed = data.Time;
    yd_data = data.Y;
    dyd_data = data.dY;
    ddyd_data = data.ddY;
    
    D = size(yd_data,1);

    dmp = cell(D);
    
    for i=1:D
        dmp{i} = DMP(N_kernels, a_z, b_z, canClockPtr);
    end
    
    %% Train the DMP
    disp('DMP training...')
    tic
    offline_train_mse = zeros(D,1); 
    n_data = size(yd_data,2);
    for i=1:D
        T = Timed;
        yd = yd_data(i,:);
        dyd = dyd_data(i,:);
        ddyd = ddyd_data(i,:);

        [offline_train_mse(i), F_train, Fd_train] = dmp{i}.train(train_method, T, yd, dyd, ddyd);      
    end
    
    offline_train_mse

    toc
    
    %% DMP simulation
    % set initial values
    y0 = yd_data(:,1);
    g0 = yd_data(:,end);
%     g0 = yd_data(:,end) * (n/2);
    g = g0;
    x = 0.0;
    dx = 0.0;
    ddy = zeros(D,1);
    dy = zeros(D,1);
    y = y0;
    t = 0.0;
    dz = zeros(D,1);
    z = zeros(D,1);

    tau = Timed(end);
    canClockPtr.setTau(tau);

    iters = 0;
    Time = [];
    y_data = [];
    dy_data = [];
    ddy_data = [];
    dz_data = [];
    x_data = [];

    disp('DMP simulation...')
    tic
    while (true)

        %% data logging

        Time = [Time t];

        y_data = [y_data y];
        dy_data = [dy_data dy];  
        ddy_data = [ddy_data ddy];

        x_data = [x_data x];

        %% DMP simulation
        for i=1:D

            y_c = 0.0;
            z_c = 0.0;

            [dy(i), dz(i)] = dmp{i}.getStatesDot(x, y(i), z(i), y0(i), g(i), y_c, z_c);

            ddy(i) = dz(i)/dmp{i}.getTau();

        end

        %% Update phase variable
        dx = canClockPtr.getPhaseDot(x);

        %% Stopping criteria
        err_p = max(abs(g0-y));
        if (err_p <= 1e-3 ...
            && t>=Timed(end))
            break; 
        end

        iters = iters + 1;
        if (t>=Timed(end) && iters>=600)
            warning('Iteration limit reached. Stopping simulation...\n');
            break;
        end

        %% Numerical integration
        t = t + dt;

        x = x + dx*dt;

        y = y + dy*dt;
        z = z + dz*dt;
        
    end
    toc
    
    Data_sim{n} = struct('Time',Time, 'Y',y_data, 'dY',dy_data, 'ddY',ddy_data);

    DMP_data{n} = dmp;
    
    figure('NumberTitle', 'off', 'Name', ['Demo ' num2str(n)]);
    for i=1:D
        subplot(D,3,(i-1)*(D+1)+1);
        plot(Time,y_data(i,:), Timed,yd_data(i,:));
        legend('dmp','demo');
        subplot(D,3,(i-1)*(D+1)+2);
        plot(Time,dy_data(i,:), Timed,dyd_data(i,:));
        subplot(D,3,(i-1)*(D+1)+3);
        plot(Time,ddy_data(i,:), Timed,ddyd_data(i,:));
    end

end

% Data = Data_sim;
% save('data/spatial_inv_data.mat', 'Data');
% return;

ax = cell(N,1);

figure;
for i=1:D
   ax{i} = subplot(D,1,i);
   ax{i}.NextPlot = 'add';
end

colors = {[0.75 0.75 0], [0.75 0 0.75], [0 0.75 0.75], [0 0 1], [0 0.5 0], [1 0.84 0], ...
    [0 0.45 0.74], [0.85 0.33 0.1], [1 0 0], [0.6 0.2 0], [1 0.6 0.78], [0.49 0.18 0.56]};

legends = cell(D,1);

for n=1:N
    dmp = DMP_data{n};
    for i=1:D
        legends{i} = [legends{i}, {['dim ' num2str(i) ' - demo ' num2str(n)]} ];
        bar(ax{i}, dmp{i}.w, 'BarWidth',1.0/n, 'FaceColor',colors{mod(n-1,length(colors))+1});
    end
end
for i=1:D
    legend(ax{i}, legends{i}, 'interpreter','latex', 'fontsize',14);
end

save('dmp_data.mat', 'DMP_data');

