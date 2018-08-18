function plot_results(Time, ind, ...
                      robot_q_data, robot_q_dot_data, robot_Pos, robot_Quat, robot_V, RobotForce_data, ...
                      human_q_data, human_q_dot_data, human_Pos, human_Quat, human_V, HumanForce_data, ...
                      barrett_weight)

    fontSize = 14;

    dt = Time(2) - Time(1);

    smooth_times = 2;
    for i=1:smooth_times
        for j=1:size(robot_V,1)
            robot_V(j,:) = smooth(robot_V(j,:),5,'moving');
            human_V(j,:) = smooth(human_V(j,:),5,'moving');
        end
    end
    
    robot_v_linear_norm = zeros(size(robot_V,2),1);
    robot_v_rot_norm = zeros(size(robot_V,2),1); 
    for i=1:length(robot_v_linear_norm)
        robot_v_linear_norm(i) = norm(robot_V(1:3,i));
        robot_v_rot_norm(i) = norm(robot_V(4:6,i));
    end
    
    human_v_linear_norm = zeros(size(human_V,2),1);
    human_v_rot_norm = zeros(size(human_V,2),1);
    for i=1:length(human_v_linear_norm)
        human_v_linear_norm(i) = norm(human_V(1:3,i));
        human_v_rot_norm(i) = norm(human_V(4:6,i));
    end
    
    vel_time = (0:length(robot_v_linear_norm)-1)*dt;
    
    ylabels = cell(7,1);
    for i=1:7
        ylabels{i} = ['joint $' num2str(i) '$'];
    end
    
    %% ==============================================================
    %% ================   Plot Joints Positions =====================
    %% ==============================================================

    figure;
    robot_q_data = robot_q_data*180*pi;
    human_q_data = human_q_data*180*pi;
    n = size(robot_q_data,1);
    for i=1:n
        subplot(size(robot_q_data,1),1,i);
        plot(vel_time, robot_q_data(i,:), 'b', vel_time, human_q_data(i,:), 'g');
    	if (i==1)
            title('Joint positions [$degrees$]','Interpreter','LaTex'); 
            legend('giver','receiver');
        end
        if (i==n), xlabel('time [$s$]','Interpreter','LaTex'); end
        ylabel(ylabels{i},'Interpreter','LaTex');
        set(gca,'fontsize',fontSize);
    end
    
    %% ===============================================================
    %% ================   Plot Joints Velocities =====================
    %% ===============================================================

    figure;
    robot_q_dot_data = robot_q_dot_data*180*pi;
    human_q_dot_data = human_q_dot_data*180*pi;
    n = size(robot_q_dot_data,1);
    for i=1:n
        subplot(size(robot_q_dot_data,1),1,i);
        plot(vel_time, robot_q_dot_data(i,:), 'b', vel_time, human_q_dot_data(i,:), 'g');
    	if (i==1)
            title('Joint velocities [$degrees/s$]','Interpreter','LaTex'); 
            legend('giver','receiver');
        end
        if (i==n), xlabel('time [$s$]','Interpreter','LaTex'); end
        ylabel(ylabels{i},'Interpreter','LaTex');
        set(gca,'fontsize',fontSize);
    end
    
    
    %% ========================================================================
    %% ================   Plot EndeEffector Velocity norm =====================
    %% ========================================================================
    
    
    %vel_time = (0:length(robot_v_linear_norm)-1)*2/length(robot_v_linear_norm);
    
    figure;
    subplot(2,1,1);
    plot(vel_time, robot_v_linear_norm, 'b', vel_time, human_v_linear_norm, 'g');
    %title('linear velocity');
    xlabel('time [$s$]','Interpreter','LaTex'); ylabel('linear velocity [$m/s$]','Interpreter','LaTex');
    legend('Giver','Receiver');
    set(gca,'fontsize',fontSize);
    subplot(2,1,2);
    plot(vel_time, robot_v_rot_norm, 'b', vel_time, human_v_rot_norm, 'g');
    %title('angular velocity');
    xlabel('time [$s$]','Interpreter','LaTex'); ylabel('angular velocity [$rad/s$]','Interpreter','LaTex');
    legend('Giver','Receiver');
    set(gca,'fontsize',fontSize);
    
    %% ==================================================================
    %% ================   Plot Endeffector velocity =====================
    %% ==================================================================
    
    ylabels = {'$v_x$ [$m/s$]', '$v_y$ [$m/s$]', '$v_z$ [$m/s$]', '$\omega_x$ [$rad/s$]', '$\omega_y [$rad/s$]$', '$\omega_z [$rad/s$]$'};
    figure;
    n = size(robot_V,1);
    for i=1:n
        subplot(n,1,i);
        plot(vel_time, robot_V(i,:), 'b', vel_time, human_V(i,:), 'g');
    	if (i==1)
            title('Endeffector velocity with respect to the camera frame','Interpreter','LaTex'); 
            legend('giver','receiver');
        end
        if (i==n), xlabel('time [$s$]','Interpreter','LaTex'); end
        ylabel(ylabels{i},'Interpreter','LaTex');
        set(gca,'fontsize',fontSize);
    end

    plot_3d_trajectory_with_frames(human_Pos, human_Quat, robot_Pos, robot_Quat);
    
    
    %% ==============================================================
    %% ================   Plot Cartesian Forces =====================
    %% ==============================================================
    
    smooth_times = 2;
    for k=1:smooth_times
        for i=1:3, RobotForce_data(3,:) = smooth(RobotForce_data(3,:),5,'moving'); end
        for i=1:3, HumanForce_data(3,:) = smooth(HumanForce_data(3,:),5,'moving'); end
    end

    red_line_offset = 1.5;
    robot_max_y = max(RobotForce_data(3,:))+red_line_offset;
    robot_min_y = min(RobotForce_data(3,:))-red_line_offset;
    human_max_y = max(HumanForce_data(3,:))+red_line_offset;
    human_min_y = min(HumanForce_data(3,:))-red_line_offset;
	
	max_y = max([robot_max_y human_max_y]);
	min_y = min([robot_min_y human_min_y]);
	
    y_offset = barrett_weight;
    figure;
    plot(Time, RobotForce_data(3,:)+y_offset,'Color','blue','Linewidth',1);
    hold on
    plot(Time, HumanForce_data(3,:)+y_offset,'Color','green','Linewidth',1);
	legend('Giver','Receiver');
    for i = 1 : length(ind)
        plot([Time(ind(i)) Time(ind(i))],[min_y max_y]+y_offset,'r--','Linewidth',1);
    end
    axis tight
    title('Giver-Receiver sensed force at the EndeEffector in the gravity direction','Interpreter','LaTex'); xlabel('time [$s$]','Interpreter','LaTex'); ylabel('Force [$N$]','Interpreter','LaTex');
    set(gca,'fontsize',fontSize);
    hold off
    
    %% ==============================================================
    %% ================   Plot Cartesian position =====================
    %% ==============================================================
    
    pos_time = (0:length(robot_Pos(1,:))-1)*dt;
    figure;
    for i=1:3
        subplot(3,1,i);
        plot(pos_time,robot_Pos(i,:),'b',pos_time,human_Pos(i,:),'g');
        ylabel('$x$-pos [$m$]','Interpreter','LaTex'); 
        if (i==3), xlabel('time [$s$]','Interpreter','LaTex'); end
        if (i==1), title('Endeffector position with respect to the camera frame'); end
        set(gca,'fontsize',fontSize);
    end

end