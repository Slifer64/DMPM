function process_data()

% clc;
% close all;
% clear;

set_matlab_utils_path();

load('data/data.mat','Data');

N = length(Data);

N_kernels = 10;
a_z = 16;
b_z = a_z/4;
train_method = 'LWR';
dt = 0.01;

canClockPtr = LinCanonicalClock();

Data_sim = cell(N,1);

for n=1:N
    
    data = Data{n};
    
    Timed = data.Time;
    yd_data = data.Y;
    dyd_data = data.dY;
    ddyd_data = data.ddY;
    
    D = size(yd_data,1);

    dmp = cell(D,1);
    
    for i=1:D
        dmp{i} = DMP(N_kernels, a_z, b_z, canClockPtr);
    end
    
    %% Train the DMP
%     disp('DMP training...')
%     tic
    offline_train_mse = zeros(D,1); 
    for i=1:D
        T = Timed;
        yd = yd_data(i,:);
        dyd = dyd_data(i,:);
        ddyd = ddyd_data(i,:);

        [offline_train_mse(i), F_train, Fd_train] = dmp{i}.train(train_method, T, yd, dyd, ddyd);      
    end
    
%     offline_train_mse

%     toc
    
    %% DMP simulation
    % set initial values
    y0 = yd_data(:,1);
    g0 = yd_data(:,end); 
    g = g0;
    x = 0.0;
    dx = 0.0;
    ddy = zeros(D,1);
    dy = zeros(D,1);
    y = y0;
    t = 0.0;
    dz = zeros(D,1);
    z = zeros(D,1);
    
    t_end = Timed(end);
    canClockPtr.setTau(t_end);

    iters = 0;
    Time = [];
    y_data = [];
    dy_data = [];
    ddy_data = [];

%     disp('DMP simulation...')
%     tic
    while (true)

        %% data logging

        Time = [Time t];

        y_data = [y_data y];
        dy_data = [dy_data dy];   
        ddy_data = [ddy_data ddy];

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
            && t>=t_end)
            break; 
        end

        iters = iters + 1;
        if (t>=t_end && iters>=600)
            warning('Iteration limit reached. Stopping simulation...\n');
            break;
        end

        %% Numerical integration
        t = t + dt;

        x = x + dx*dt;

        y = y + dy*dt;
        z = z + dz*dt;
        
    end
%     toc
    
    Data_sim{n} = struct('Time',Time, 'Y',y_data, 'dY',dy_data, 'ddY',ddy_data);
    
    disp(['Processed demo' num2str(n) '/' num2str(N) ]);
     
end

plot_demos(Data_sim);

Data = Data_sim;
save('data/data.mat','Data');

end