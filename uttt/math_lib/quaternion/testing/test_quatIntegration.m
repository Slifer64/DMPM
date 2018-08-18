%% Test the quaternion integration using the exp and log mappings.
%% In the first case the rotational velocity is produced by the vector part of the quaternion difference.
%% In the second case the rotational velocity is produced by the log map of the quaternion difference.
%% In both cases, the quaternion integration is implemented using the exp map.

clc;
close all;
clear;

%% Initialize
dt = 0.01;
tol_stop = 5e-3;

Q_start = rand(4,1);
Q_start = Q_start/norm(Q_start);

Q_target = rand(4,1);
Q_target = Q_target/norm(Q_target);
%Q_target = [1 0 0 0]';


%% Simulate with v_rot produced by the vector part of the quaternion diff
Q_data = [];
Q_01 = Q_start;
Q_02 = Q_target;
while (quatDist(Q_01,Q_02) > tol_stop)
    Q_21 = quatProd(quatInv(Q_02),Q_01);

    v_rot = -1.5*Q_21(2:4);
    
    dQ = quatExp(v_rot*dt);
    
    Q_21 = quatProd(dQ, Q_21);
    
    Q_01 = quatProd(Q_02,Q_21); 
    
    Q_data = [Q_data Q_01];
end


%% Simulate with v_rot produced by the log map of the quaternion diff
Q_data2 = [];
Q_01 = Q_start;
Q_02 = Q_target;
while (quatDist(Q_01,Q_02) > tol_stop)
    Q_21 = quatProd(quatInv(Q_02),Q_01);

    v_rot = -0.8*quatLog(Q_21);
    
    dQ = quatExp(v_rot*dt);
    
    Q_21 = quatProd(dQ, Q_21);
    
    Q_01 = quatProd(Q_02,Q_21); 
    
    Q_data2 = [Q_data2 Q_01];
end


%% Plot results
Lwidth = 1.5;
markSize = 8;

T = (0:size(Q_data,2)-1)*dt;
T2 = (0:size(Q_data2,2)-1)*dt;
Tmax = max([max(T) max(T2)]);
figure;
subplot(2,2,1);
plot(T,Q_data(1,:),T2,Q_data2(1,:),[0 Tmax],[Q_02(1) Q_02(1)],'r--','MarkerSize',markSize,'LineWidth',Lwidth);
legend('n','n_2');
subplot(2,2,2);
plot(T,Q_data(2,:),T2,Q_data2(2,:),[0 Tmax],[Q_02(2) Q_02(2)],'r--','MarkerSize',markSize,'LineWidth',Lwidth);
legend('e1','e1_2');
subplot(2,2,3);
plot(T,Q_data(3,:),T2,Q_data2(3,:),[0 Tmax],[Q_02(3) Q_02(3)],'r--','MarkerSize',markSize,'LineWidth',Lwidth);
legend('e2','e2_2');
subplot(2,2,4);
plot(T,Q_data(4,:),T2,Q_data2(4,:),[0 Tmax],[Q_02(4) Q_02(4)],'r--','MarkerSize',markSize,'LineWidth',Lwidth);
legend('e3','e3_2');

