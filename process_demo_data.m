function process_demo_data()

% close all;
% clc;
% clear;

load('data/demos.mat','demo_data');

N = length(demo_data);

Data = cell(N,1);

Ts = 0.01;

for n=1:N
    data = demo_data{n}';
    
    data_dot = [zeros(2,1) diff(data,1,2)]/Ts;
    
%     for i=1:size(data_dot,1)
%         data_dot(i,:) = smooth(data_dot(i,:),10,'moving');
%         data_dot(i,:) = smooth(data_dot(i,:),10,'moving');
%     end
    
    data_ddot = [zeros(2,1) diff(data_dot,1,2)]/Ts;
    
    Time = (0:(size(data,2)-1))*Ts;
    
    Data{n} = struct('Time',Time, 'Y',data, 'dY',data_dot, 'ddY',data_ddot);
    
    disp(['Processed demo' num2str(n) '/' num2str(N) ]);
    
end

plot_demos(Data);

save('data/data.mat','Data');

end