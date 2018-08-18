%% ************************************************************************
%% ************************************************************************

function robot_main_ode_lwr4(USE_SEDS_PARAMS, timeStamp)
	
    clc; close all;
    format compact;
    format longE;
    
	%% ***  load the robot_camera transform  ***
	T_robot_cam = load_robot_camera_transform();
	T_cam_robot = inv(T_robot_cam);
	
	%% ***  initialize SEDS  ***
	seds = SEDS();
	
    %% ***  load initial values of robot joints  ***
	[fid, errmsg] = fopen('T_robot_endEffector.txt');
	q0 = zeros(7,1);
    if (fid == -1)
        warning([errmsg '\nAll joint values will be initialized to zero.\n']);
    else
        q0 = fscanf(fid,'%f',7);
		fclose(fid);
    end
	
	%% ***  get the camera_object transform  ***
	T_endEffector_obj = eye(4);
	
    %% ***  get the robot_endEffector transform  ***
	T_robot_endEffector = lwr4_fkine(q0);
	T_cam_target = get_cam_target_transform();
    
    T_robot_cam = T_robot_endEffector;
    T_cam_robot = inv(T_robot_cam);
    
%     T_robot_cam
%     T_robot_endEffector
%     T_cam_target
%     pause
    
	Ts = 0.02;
	
    %% *** control loop ***

    tspan = [1 15];
    
    if (USE_SEDS_PARAMS)
        opts = odeset('RelTol',1e-7, 'AbsTol',1e-9, 'Events',@robot_sedsParams_event_fun, 'OutputFcn', @odeplot);
        T_target_obj = T_cam_target \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;
        pos_quat = transform_to_pos_quat(T_target_obj);
        s0 = pos_quat';
        
        [T, s] = ode45(@(t,s)robot_sedsParams_ode_fun(t, s, seds), tspan, s0, opts);
        
        Pos_Quat = s';
        X = [Pos_Quat(1:3,:); Pos_Quat(5:7,:)];
        V = seds.get_seds_output(X);
    else
        robot_FRI_event_fun_wrapper = @(t,s)robot_FRI_event_fun(t,s,T_cam_robot,T_endEffector_obj);
        ode_outfun = @(t,s,flag)FRI_odeplot(t,s,flag,T_cam_robot,T_endEffector_obj);
        opts = odeset('RelTol',1e-7, 'AbsTol',1e-9, 'Events',robot_FRI_event_fun_wrapper, 'OutputFcn',ode_outfun);
        s0 = q0;
        
        [T, s] = ode45(@(t,s)robot_FRI_ode_fun(t, s, seds, T_cam_robot, T_endEffector_obj), tspan, s0, opts);
        
        q = s';
        X = zeros(6,size(q,2));
        Pos_Quat = zeros(7,size(q,2));
        for i=1:size(q,2)
            T_robot_endEffector = lwr4_fkine(q(:,i));
            T_target_obj = get_cam_target_transform() \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;
            pos_quat = transform_to_pos_quat(T_target_obj);
            X(:,i) = [pos_quat(1:3); pos_quat(5:7)];
            Pos_Quat(:,i) = pos_quat;
        end
        V = seds.get_seds_output(X);
    end
    
    step = ceil(length(T)/1000);
    Pos = Pos_Quat(1:3,1:step:end);
    Axang = quat2axang(Pos_Quat(4:7,1:step:end)')';
    T = T(1:step:end);
    V = V(:,1:step:end);
	
    %% plot position and orientation errors
	plot_pos_orient_errors(T,X);

    plot_linear_and_rot_velocities(T,V);
    
    %% animate the endEffector's trajectory to the target
    %animated_trajectory_endEffector_to_target(T, Pos, Axang);
    
    plot3d_trajectory(T, Pos, Axang);

    %% write endEffector's trajectory to wrl file
    write_wrl(['wrl_files/' timeStamp], Pos*10, Axang, T);
	
	display('Exiting robot_main...\n');
end

%% ************************************************************************
%% ************************************************************************

function plot_pos_orient_errors(T,X)
    figure;
	subplot(2,1,1);
	plot(T, X(1:3,:));
	legend('e_x','e_y','e_z');
	subplot(2,1,2);
	plot(T, X(4:6,:));
	legend('e0_1','e0_2','e0_3');
end

function plot_linear_and_rot_velocities(T,V)
    figure;
	subplot(2,1,1);
	plot(T, V(1:3,:));
	legend('v_x','v_y','v_z');
	subplot(2,1,2);
	plot(T, V(4:6,:));
	legend('ù_x','ù_y','ù_z');
end

function plot3d_trajectory(T, Pos, Axang)

X = Pos(1,:);
Y = Pos(2,:);
Z = Pos(3,:);

U = Axang(1,:);
V = Axang(2,:);
W = Axang(3,:);

scale = 0.6;

figH = figure;
set(groot,'CurrentFigure',figH); % set this figure as the current figure
ax = gca; % get the axis of the current figure
view(3);

% plot on the axis of the handle 'ax'
hold on;
quiver3(ax,X,Y,Z,U,V,W,scale, ...
        'Color','blue', 'LineStyle','-', 'LineWidth',0.8, ...
        'Marker','o', 'MarkerSize',5, 'MarkerEdgeColor','red');
title('3d oriented trajectory of endEffector');

plot3(ax, X(1),Y(1),Z(1),'go','MarkerSize',12,'LineWidth',3);
text(X(1),Y(1),Z(1),'start');
plot3(ax,X(end),Y(end),Z(end),'gx','MarkerSize',12,'LineWidth',3);
text(X(end),Y(end),Z(end),'end');

hold off

end

function animated_trajectory_endEffector_to_target(T, Pos, Axang)
    figure;
    pos_scale = 20;
    ax_max = pos_scale * ( max(abs(Pos(1:3,1))) + 0.0);
    ax_min = -ax_max;

    ax = axes('XLim',[ax_min ax_max],'YLim',[ax_min ax_max],'ZLim',[ax_min ax_max]);
    view([-75.5, 40]);
    %view(3);
    grid on

    frame_scale = 1;
    endEffector_frame = get_frame_handle(frame_scale,1);
    set(endEffector_frame,'Parent',ax);
    target_frame = get_frame_handle(frame_scale,0.4);
    set(target_frame,'Parent',ax);
    
    endEffector_trace = animatedline('Color','red', 'LineStyle','--', 'LineWidth',0.75, 'Marker','*', 'MarkerSize',6);
    set(endEffector_trace,'Parent',ax);
    
    drawnow
    
    pause
    % use this matrix to implicitly change the viewpoint by changing the positions of the axes
    T_yzx0 = [0 0 1 0; 1 0 0 0; 0 1 0 0; 0 0 0 1];
    set(target_frame, 'Matrix',T_yzx0);
    for i=2:size(Pos,2)
        T_target_endEffector = T_yzx0 * makehgtform('translate',pos_scale*Pos(:,i)') * makehgtform('axisrotate',Axang(1:3,i)',Axang(4,i));
        set(endEffector_frame, 'Matrix',T_target_endEffector);
        point_trace = T_yzx0(1:3,1:3) * pos_scale*Pos(:,i);
        addpoints(endEffector_trace,point_trace(1),point_trace(2),point_trace(3));
        drawnow
        pause(T(i)-T(i-1))
    end


end

%% ************************************************************************
%% ************************************************************************

function status = FRI_odeplot(t,s,flag,T_cam_robot,T_endEffector_obj)

global figH sp1H sp2H animeLineH

if (strcmpi(flag,'init'))
    figH = figure('Name','FRI odeplot','NumberTitle','off');
    set(groot,'CurrentFigure',figH); % Set this figure as the current one.
    sp1H = subplot(2,1,1); % Create and activate subplot 1.
    set(sp1H,'Parent',figH);
    xlim(t)
    sp2H = subplot(2,1,2); % Create and activate subplot 2.
    set(sp2H,'Parent',figH);
    xlim(t)
    
    % Create the animated lines. Initially these lines will have as parent
    % the current active supblot, that is subplot 2. We overwrite that
    % later on.
    animeLineH = [animatedline; animatedline; animatedline; animatedline; animatedline; animatedline];
    animeLineH(1).Color = [0 0 1]; % blue
    animeLineH(2).Color = [0 1 0]; % green
    animeLineH(3).Color = [1 0 0]; % red
    animeLineH(4).Color = [0 1 1]; % white blue
    animeLineH(5).Color = [1 0 1]; % magenta
    animeLineH(6).Color = [0.2 0.5 0.4];
    
    % Assign the first 3 lines to the 1st subplot and the last 3 lines to
    % the 2nd subplot
    set(animeLineH(1:3),'Parent',sp1H);
    set(animeLineH(4:6),'Parent',sp2H);

    q = s;
    T_robot_endEffector = lwr4_fkine(q);
    T_target_obj = get_cam_target_transform() \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;
    pos_quat = transform_to_pos_quat(T_target_obj);
    X = [pos_quat(1:3); pos_quat(5:7)];

    % Activate sp1 so that the legend command 'legend('e_x','e_y','e_z');' will assign 
    % the legend to this subplot. The animeLines are already assigned so if we were to 
    % omit the kernel of sp1, the lines would be still plotted in the right subplot.
    subplot(sp1H) 
    for k=1:3
        addpoints(animeLineH(k),t(1),X(k));
    end
    title('position errors');
    legend('e_x','e_y','e_z');
    
    % Activate sp2 so that the legend command 'legend('e0_1','e0_2','e0_3');' will assign 
    % the legend to this subplot. The animeLines are already assigned so if we were to 
    % omit the kernel of sp1, the lines would be still plotted in the right subplot.
    subplot(sp2H)
    for k=4:6
        addpoints(animeLineH(k),t(1),X(k));
    end
    title('orientation errors');
    legend('e0_1','e0_2','e0_3');
    
    drawnow;
elseif (isempty(flag))
    for i=1:length(t)
        q = s(:,i);
        T_robot_endEffector = lwr4_fkine(q);
        T_target_obj = get_cam_target_transform() \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;
        pos_quat = transform_to_pos_quat(T_target_obj);
        X = [pos_quat(1:3); pos_quat(5:7)];

        % Even if another figure is the current figure, these lines will be
        % plotted in the right subplots, namely in their parents
        for k=1:3
            addpoints(animeLineH(k),t(1),X(k));
        end
        for k=4:6
            addpoints(animeLineH(k),t(1),X(k));
        end
    end
    drawnow;
elseif (strcmpi(flag,'done'))
    clear figH sp1H sp2H animeLineH
end

status = 0;

end

function ds = robot_FRI_ode_fun(t, s, seds, T_cam_robot, T_endEffector_obj)

q = s;

T_robot_endEffector = lwr4_fkine(q);
T_cam_target = get_cam_target_transform();
T_target_obj = T_cam_target \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;

V_target_obj = seds.get_V(T_target_obj);

V_obj_obj(1:3) = T_target_obj(1:3,1:3)' * V_target_obj(1:3);
V_obj_obj(4:6) = T_target_obj(1:3,1:3)' * V_target_obj(4:6);
V_obj_obj = V_obj_obj(:);

Torsion_endEffector_obj = [T_endEffector_obj(1:3,1:3), vector2ssMatrix(T_endEffector_obj(1:3,4))*T_endEffector_obj(1:3,1:3);
                                   zeros(3,3)        ,             T_endEffector_obj(1:3,1:3)];


V_endEffector = Torsion_endEffector_obj * V_obj_obj;
J_endEffector = lwr4_jacob(q);
% because we use the simulated FRI, we get the robot jacobian.
% If we were using the real FRI, we would get the endEffector jacobian.
J_robot = J_endEffector;
J_endEffector = [T_robot_endEffector(1:3,1:3)', zeros(3,3); zeros(3,3), T_robot_endEffector(1:3,1:3)'] * J_robot;

K_p_o = zeros(6,1); %[0.5 0.5 0.5 0.45 0.45 0.45]';
e_p_o = seds.transform_to_sedsParams(T_target_obj);
%q_dot = pinv(J_endEffector)*(V_endEffector - K_p_o.*e_p_o);
q_dot = pinv(J_endEffector)*(V_endEffector - K_p_o.*e_p_o);

ds = q_dot;

q_dot
V_endEffector

end

function [value,isterminal,direction] = robot_FRI_event_fun(t,s,T_cam_robot,T_endEffector_obj)

q = s;
T_robot_endEffector = lwr4_fkine(q);
T_target_obj = get_cam_target_transform() \ T_cam_robot * T_robot_endEffector * T_endEffector_obj;

pos_quat = transform_to_pos_quat(T_target_obj);
s = [pos_quat(1:3); pos_quat(5:7)];
isterminal = 1;
direction = 0;
value = double(~(norm(s) < 1e-3));
    
end


function ds = robot_sedsParams_ode_fun(t, s, seds)

pos_quat = s;
T_target_obj = pos_quat_to_transform(pos_quat);

V_target_obj = seds.get_V(T_target_obj);

dpos_dquat = get_dpos_dquat(V_target_obj, pos_quat);

ds = dpos_dquat;

end

function [value,isterminal,direction] = robot_sedsParams_event_fun(t,s)

isterminal = 1;
direction = 0;
value = double(~(norm([s(1:3); s(5:7)]) < 1e-3));
    
end

%% ************************************************************************
%% ************************************************************************

function T_robot_cam = load_robot_camera_transform()
	T_robot_cam = eye(4);
	
	[fid, errmsg] = fopen('T_robot_cam.txt');
	if (fid == -1)
		warning(errmsg);
		fclose(fid);
		return;
	end
	
	for i=1:3
		for j=1:4
			T_robot_cam(i,j) = fscanf(fid,'%f',1);
		end
	end
	
	fclose(fid);
end

function T_cam_target = get_cam_target_transform()
	T_cam_target = eye(4);
    % Q = [0.87625777506449 0.46058051784767 -0.11721267415858 0.07936678924329];
	Q = [0.57625777506449 0.46058051784767 -0.41721267415858 0.37936678924329];
    Q = Q / norm(Q);
	T_cam_target(1:3,1:3) = quat2rotm(Q);
	T_cam_target(1:3,4) = [0.11885738384402 -0.09965246838861 0.12991069886510]';
end

%% ************************************************************************
%% ************************************************************************

function pos_quat = transform_to_pos_quat(T)
	pos_quat = zeros(7,1);
	pos_quat(1:3) = T(1:3,4);
	
	quat = rotm2quat(T(1:3,1:3))';
	pos_quat(4:end) = quat;
end
		
function T = pos_quat_to_transform(pos_quat)
	T = eye(4);
	T(1:3,4) = pos_quat(1:3);
	T(1:3,1:3) = quat2rotm(pos_quat(4:7)');
end
		

%% ************************************************************************
%% ************************************************************************


function Ja = lwr4_jacob(q)
    s=[0,0,0,0,0,0,0]';  
    c=s;
    for i=1:7
        c(i) = cos(q(i));
        s(i) = sin(q(i));
    end
    Ja(1,1)   =  0.4*s(1)*s(2)+0.39*c(4)*s(1)*s(2)-0.39*c(1)*s(3)*s(4)-0.39*c(2)*c(3)*s(1)*s(4)+0.088*c(4)*c(6)*s(1)*s(2)-0.088*c(1)*c(6)*s(3)*s(4)+0.088*c(1)*c(3)*s(5)*s(6)-0.088*c(2)*s(1)*s(3)*s(5)*s(6)+0.088*c(5)*s(1)*s(2)*s(4)*s(6)-0.088*c(2)*c(3)*c(6)*s(1)*s(4)+0.088*c(1)*c(4)*c(5)*s(3)*s(6)+0.088*c(2)*c(3)*c(4)*c(5)*s(1)*s(6);
    Ja(1,2)   = -c(1)*(0.4*c(2)+0.39*c(2)*c(4)+0.088*c(2)*c(4)*c(6)+0.39*c(3)*s(2)*s(4)+0.088*c(3)*c(6)*s(2)*s(4)+0.088*c(2)*c(5)*s(4)*s(6)+0.088*s(2)*s(3)*s(5)*s(6)-0.088*c(3)*c(4)*c(5)*s(2)*s(6));
    Ja(1,3)   =  0.088*c(1)*c(2)*c(3)*s(5)*s(6)-0.39*c(3)*s(1)*s(2)^2*s(4)-0.39*c(1)*c(2)*s(3)*s(4)-0.088*c(2)^2*c(3)*c(6)*s(1)*s(4)-0.088*c(3)*c(6)*s(1)*s(2)^2*s(4)-0.088*c(2)^2*s(1)*s(3)*s(5)*s(6)-0.088*s(1)*s(2)^2*s(3)*s(5)*s(6)-0.088*c(1)*c(2)*c(6)*s(3)*s(4)-0.39*c(2)^2*c(3)*s(1)*s(4)+0.088*c(1)*c(2)*c(4)*c(5)*s(3)*s(6)+0.088*c(2)^2*c(3)*c(4)*c(5)*s(1)*s(6)+0.088*c(3)*c(4)*c(5)*s(1)*s(2)^2*s(6);
    Ja(1,4)   =  0.39*c(1)*c(3)^2*s(2)*s(4)-0.39*c(2)^2*c(4)*s(1)*s(3)+0.39*c(1)*s(2)*s(3)^2*s(4)-0.39*c(4)*s(1)*s(2)^2*s(3)+0.39*c(1)*c(2)*c(3)*c(4)+0.088*c(1)*c(3)^2*c(6)*s(2)*s(4)-0.088*c(2)^2*c(4)*c(6)*s(1)*s(3)+0.088*c(1)*c(6)*s(2)*s(3)^2*s(4)-0.088*c(4)*c(6)*s(1)*s(2)^2*s(3)+0.088*c(1)*c(2)*c(3)*c(4)*c(6)-0.088*c(5)*s(1)*s(2)^2*s(3)*s(4)*s(6)+0.088*c(1)*c(2)*c(3)*c(5)*s(4)*s(6)-0.088*c(1)*c(3)^2*c(4)*c(5)*s(2)*s(6)-0.088*c(1)*c(4)*c(5)*s(2)*s(3)^2*s(6)-0.088*c(2)^2*c(5)*s(1)*s(3)*s(4)*s(6);
    Ja(1,5)   =  s(6)*(0.088*c(5)*s(1)*c(2)^2*c(3)*c(4)^2+0.088*c(5)*s(1)*c(2)^2*c(3)*s(4)^2-0.088*s(1)*s(5)*c(2)^2*c(4)*s(3)+0.088*c(1)*s(5)*c(2)*c(3)*c(4)+0.088*c(1)*c(5)*c(2)*c(4)^2*s(3)+0.088*c(1)*c(5)*c(2)*s(3)*s(4)^2+0.088*c(1)*s(5)*c(3)^2*s(2)*s(4)+0.088*c(5)*s(1)*c(3)*c(4)^2*s(2)^2+0.088*c(5)*s(1)*c(3)*s(2)^2*s(4)^2-0.088*s(1)*s(5)*c(4)*s(2)^2*s(3)+0.088*c(1)*s(5)*s(2)*s(3)^2*s(4));
    Ja(1,6)   =  0.088*c(6)*s(1)*c(2)^2*c(3)*c(4)^2*s(5)+0.088*c(6)*s(1)*c(2)^2*c(3)*s(4)^2*s(5)+0.088*c(6)*s(1)*c(2)^2*c(4)*c(5)*s(3)+0.088*s(1)*s(6)*c(2)^2*c(5)^2*s(3)*s(4)+0.088*s(1)*s(6)*c(2)^2*s(3)*s(4)*s(5)^2-0.088*c(1)*c(6)*c(2)*c(3)*c(4)*c(5)-0.088*c(1)*s(6)*c(2)*c(3)*c(5)^2*s(4)-0.088*c(1)*s(6)*c(2)*c(3)*s(4)*s(5)^2+0.088*c(1)*c(6)*c(2)*c(4)^2*s(3)*s(5)+0.088*c(1)*c(6)*c(2)*s(3)*s(4)^2*s(5)+0.088*c(1)*s(6)*c(3)^2*c(4)*c(5)^2*s(2)+0.088*c(1)*s(6)*c(3)^2*c(4)*s(2)*s(5)^2-0.088*c(1)*c(6)*c(3)^2*c(5)*s(2)*s(4)+0.088*c(6)*s(1)*c(3)*c(4)^2*s(2)^2*s(5)+0.088*c(6)*s(1)*c(3)*s(2)^2*s(4)^2*s(5)+0.088*c(1)*s(6)*c(4)*c(5)^2*s(2)*s(3)^2+0.088*c(6)*s(1)*c(4)*c(5)*s(2)^2*s(3)+0.088*c(1)*s(6)*c(4)*s(2)*s(3)^2*s(5)^2+0.088*s(1)*s(6)*c(5)^2*s(2)^2*s(3)*s(4)-0.088*c(1)*c(6)*c(5)*s(2)*s(3)^2*s(4)+0.088*s(1)*s(6)*s(2)^2*s(3)*s(4)*s(5)^2;
    Ja(1,7)   =  0;
    Ja(2,1)   =  0.39*c(1)*c(2)*c(3)*s(4)-0.39*c(1)*c(4)*s(2)-0.39*s(1)*s(3)*s(4)-0.4*c(1)*s(2)-0.088*c(1)*c(4)*c(6)*s(2)-0.088*c(6)*s(1)*s(3)*s(4)+0.088*c(3)*s(1)*s(5)*s(6)+0.088*c(1)*c(2)*s(3)*s(5)*s(6)-0.088*c(1)*c(5)*s(2)*s(4)*s(6)+0.088*c(4)*c(5)*s(1)*s(3)*s(6)+0.088*c(1)*c(2)*c(3)*c(6)*s(4)-0.088*c(1)*c(2)*c(3)*c(4)*c(5)*s(6);
    Ja(2,2)   = -s(1)*(0.4*c(2)+0.39*c(2)*c(4)+0.088*c(2)*c(4)*c(6)+0.39*c(3)*s(2)*s(4)+0.088*c(3)*c(6)*s(2)*s(4)+0.088*c(2)*c(5)*s(4)*s(6)+0.088*s(2)*s(3)*s(5)*s(6)-0.088*c(3)*c(4)*c(5)*s(2)*s(6));
    Ja(2,3)   =  0.39*c(1)*c(2)^2*c(3)*s(4)+0.39*c(1)*c(3)*s(2)^2*s(4)-0.39*c(2)*s(1)*s(3)*s(4)-0.088*c(2)*c(6)*s(1)*s(3)*s(4)+0.088*c(2)*c(3)*s(1)*s(5)*s(6)+0.088*c(1)*c(2)^2*c(3)*c(6)*s(4)+0.088*c(1)*c(3)*c(6)*s(2)^2*s(4)+0.088*c(1)*c(2)^2*s(3)*s(5)*s(6)+0.088*c(1)*s(2)^2*s(3)*s(5)*s(6)+0.088*c(2)*c(4)*c(5)*s(1)*s(3)*s(6)-0.088*c(1)*c(2)^2*c(3)*c(4)*c(5)*s(6)-0.088*c(1)*c(3)*c(4)*c(5)*s(2)^2*s(6);
    Ja(2,4)   =  0.39*c(1)*c(2)^2*c(4)*s(3)+0.39*c(1)*c(4)*s(2)^2*s(3)+0.39*c(3)^2*s(1)*s(2)*s(4)+0.39*s(1)*s(2)*s(3)^2*s(4)+0.39*c(2)*c(3)*c(4)*s(1)+0.088*c(1)*c(2)^2*c(4)*c(6)*s(3)+0.088*c(1)*c(4)*c(6)*s(2)^2*s(3)+0.088*c(3)^2*c(6)*s(1)*s(2)*s(4)+0.088*c(6)*s(1)*s(2)*s(3)^2*s(4)+0.088*c(2)*c(3)*c(4)*c(6)*s(1)+0.088*c(2)*c(3)*c(5)*s(1)*s(4)*s(6)+0.088*c(1)*c(2)^2*c(5)*s(3)*s(4)*s(6)-0.088*c(3)^2*c(4)*c(5)*s(1)*s(2)*s(6)+0.088*c(1)*c(5)*s(2)^2*s(3)*s(4)*s(6)-0.088*c(4)*c(5)*s(1)*s(2)*s(3)^2*s(6);
    Ja(2,5)   =  s(6)*(0.088*c(1)*s(5)*c(2)^2*c(4)*s(3)-0.088*c(1)*c(5)*c(2)^2*c(3)*s(4)^2-0.088*c(1)*c(5)*c(2)^2*c(3)*c(4)^2+0.088*s(1)*s(5)*c(2)*c(3)*c(4)+0.088*c(5)*s(1)*c(2)*c(4)^2*s(3)+0.088*c(5)*s(1)*c(2)*s(3)*s(4)^2+0.088*s(1)*s(5)*c(3)^2*s(2)*s(4)-0.088*c(1)*c(5)*c(3)*c(4)^2*s(2)^2-0.088*c(1)*c(5)*c(3)*s(2)^2*s(4)^2+0.088*c(1)*s(5)*c(4)*s(2)^2*s(3)+0.088*s(1)*s(5)*s(2)*s(3)^2*s(4));
    Ja(2,6)   =  0.088*c(6)*s(1)*c(2)*c(4)^2*s(3)*s(5)-0.088*c(1)*c(6)*c(2)^2*c(3)*s(4)^2*s(5)-0.088*c(1)*c(6)*c(2)^2*c(4)*c(5)*s(3)-0.088*c(1)*s(6)*c(2)^2*c(5)^2*s(3)*s(4)-0.088*c(1)*s(6)*c(2)^2*s(3)*s(4)*s(5)^2-0.088*c(6)*s(1)*c(2)*c(3)*c(4)*c(5)-0.088*s(1)*s(6)*c(2)*c(3)*c(5)^2*s(4)-0.088*s(1)*s(6)*c(2)*c(3)*s(4)*s(5)^2-0.088*c(1)*c(6)*c(2)^2*c(3)*c(4)^2*s(5)+0.088*c(6)*s(1)*c(2)*s(3)*s(4)^2*s(5)+0.088*s(1)*s(6)*c(3)^2*c(4)*c(5)^2*s(2)+0.088*s(1)*s(6)*c(3)^2*c(4)*s(2)*s(5)^2-0.088*c(6)*s(1)*c(3)^2*c(5)*s(2)*s(4)-0.088*c(1)*c(6)*c(3)*c(4)^2*s(2)^2*s(5)-0.088*c(1)*c(6)*c(3)*s(2)^2*s(4)^2*s(5)+0.088*s(1)*s(6)*c(4)*c(5)^2*s(2)*s(3)^2-0.088*c(1)*c(6)*c(4)*c(5)*s(2)^2*s(3)+0.088*s(1)*s(6)*c(4)*s(2)*s(3)^2*s(5)^2-0.088*c(1)*s(6)*c(5)^2*s(2)^2*s(3)*s(4)-0.088*c(6)*s(1)*c(5)*s(2)*s(3)^2*s(4)-0.088*c(1)*s(6)*s(2)^2*s(3)*s(4)*s(5)^2;
    Ja(2,7)   =  0; 
    Ja(3,1)   =  0;
    Ja(3,2)   = -(c(1)^2+s(1)^2)*(0.4*s(2)+0.39*c(4)*s(2)-0.39*c(2)*c(3)*s(4)+0.088*c(4)*c(6)*s(2)-0.088*c(2)*c(3)*c(6)*s(4)-0.088*c(2)*s(3)*s(5)*s(6)+0.088*c(5)*s(2)*s(4)*s(6)+0.088*c(2)*c(3)*c(4)*c(5)*s(6));
    Ja(3,3)   = -s(2)*(c(1)^2+s(1)^2)*(0.39*s(3)*s(4)+0.088*c(6)*s(3)*s(4)-0.088*c(3)*s(5)*s(6)-0.088*c(4)*c(5)*s(3)*s(6));
    Ja(3,4)   =  (c(1)^2+s(1)^2)*(0.39*c(3)*c(4)*s(2)-0.39*c(2)*c(3)^2*s(4)-0.39*c(2)*s(3)^2*s(4)-0.088*c(2)*c(3)^2*c(6)*s(4)-0.088*c(2)*c(6)*s(3)^2*s(4)+0.088*c(3)*c(4)*c(6)*s(2)+0.088*c(3)*c(5)*s(2)*s(4)*s(6)+0.088*c(2)*c(3)^2*c(4)*c(5)*s(6)+0.088*c(2)*c(4)*c(5)*s(3)^2*s(6));
    Ja(3,5)   =  s(6)*(c(1)^2+s(1)^2)*(0.088*s(2)*s(5)*c(3)*c(4)-0.088*c(2)*s(5)*c(3)^2*s(4)+0.088*c(5)*s(2)*c(4)^2*s(3)-0.088*c(2)*s(5)*s(3)^2*s(4)+0.088*c(5)*s(2)*s(3)*s(4)^2);
    Ja(3,6)   = -(c(1)^2+s(1)^2)*(0.088*c(2)*s(6)*c(3)^2*c(4)*c(5)^2+0.088*c(2)*s(6)*c(3)^2*c(4)*s(5)^2-0.088*c(2)*c(6)*c(3)^2*c(5)*s(4)+0.088*c(6)*s(2)*c(3)*c(4)*c(5)+0.088*s(2)*s(6)*c(3)*c(5)^2*s(4)+0.088*s(2)*s(6)*c(3)*s(4)*s(5)^2-0.088*c(6)*s(2)*c(4)^2*s(3)*s(5)+0.088*c(2)*s(6)*c(4)*c(5)^2*s(3)^2+0.088*c(2)*s(6)*c(4)*s(3)^2*s(5)^2-0.088*c(2)*c(6)*c(5)*s(3)^2*s(4)-0.088*c(6)*s(2)*s(3)*s(4)^2*s(5)); 
    Ja(3,7)   =  0;
    Ja(4,1)   =  0;
    Ja(4,2)   =  s(1);
    Ja(4,3)   = -c(1)*s(2);
    Ja(4,4)   = -c(3)*s(1)-c(1)*c(2)*s(3);
    Ja(4,5)   =  c(1)*c(2)*c(3)*s(4)-s(1)*s(3)*s(4)-c(1)*c(4)*s(2);
    Ja(4,6)   =  c(3)*c(5)*s(1)+c(1)*c(2)*c(5)*s(3)+c(1)*s(2)*s(4)*s(5)-c(4)*s(1)*s(3)*s(5)+c(1)*c(2)*c(3)*c(4)*s(5);
    Ja(4,7)   =  c(3)*s(1)*s(5)*s(6)-c(6)*s(1)*s(3)*s(4)-c(1)*c(4)*c(6)*s(2)+c(1)*c(2)*s(3)*s(5)*s(6)-c(1)*c(5)*s(2)*s(4)*s(6)+c(4)*c(5)*s(1)*s(3)*s(6)+c(1)*c(2)*c(3)*c(6)*s(4)-c(1)*c(2)*c(3)*c(4)*c(5)*s(6);
    Ja(5,1)   =  0;
    Ja(5,2)   = -c(1);
    Ja(5,3)   = -s(1)*s(2);
    Ja(5,4)   =  c(1)*c(3)-c(2)*s(1)*s(3);
    Ja(5,5)   =  c(1)*s(3)*s(4)-c(4)*s(1)*s(2)+c(2)*c(3)*s(1)*s(4);
    Ja(5,6)   =  c(2)*c(5)*s(1)*s(3)-c(1)*c(3)*c(5)+c(1)*c(4)*s(3)*s(5)+s(1)*s(2)*s(4)*s(5)+c(2)*c(3)*c(4)*s(1)*s(5);
    Ja(5,7)   =  c(1)*c(6)*s(3)*s(4)-c(4)*c(6)*s(1)*s(2)-c(1)*c(3)*s(5)*s(6)+c(2)*s(1)*s(3)*s(5)*s(6)-c(5)*s(1)*s(2)*s(4)*s(6)+c(2)*c(3)*c(6)*s(1)*s(4)-c(1)*c(4)*c(5)*s(3)*s(6)-c(2)*c(3)*c(4)*c(5)*s(1)*s(6);
    Ja(6,1)   =  1;
    Ja(6,2)   =  0;
    Ja(6,3)   =  c(2);
    Ja(6,4)   = -s(2)*s(3);
    Ja(6,5)   =  c(2)*c(4)+c(3)*s(2)*s(4);
    Ja(6,6)   =  c(5)*s(2)*s(3)-c(2)*s(4)*s(5)+c(3)*c(4)*s(2)*s(5);
    Ja(6,7)   =  c(2)*c(4)*c(6)+c(3)*c(6)*s(2)*s(4)+c(2)*c(5)*s(4)*s(6)+s(2)*s(3)*s(5)*s(6)-c(3)*c(4)*c(5)*s(2)*s(6);
end

function fk = lwr4_fkine(q)
    s=[0,0,0,0,0,0,0]';  
    c=s;
    for i=1:7
        c(i) = cos(q(i));
        s(i) = sin(q(i));
    end

    fk(1,1)   = c(4)*s(1)*s(3)*s(5)*s(7)-c(1)*s(2)*s(4)*s(5)*s(7)-c(3)*c(5)*s(1)*s(7)-c(7)*s(1)*s(3)*s(4)*s(6)-c(1)*c(2)*c(5)*s(3)*s(7)-c(1)*c(4)*c(7)*s(2)*s(6)-c(3)*c(6)*c(7)*s(1)*s(5)-c(1)*c(2)*c(3)*c(4)*s(5)*s(7)+c(1)*c(2)*c(3)*c(7)*s(4)*s(6)-c(1)*c(2)*c(6)*c(7)*s(3)*s(5)+c(1)*c(5)*c(6)*c(7)*s(2)*s(4)-c(4)*c(5)*c(6)*c(7)*s(1)*s(3)+c(1)*c(2)*c(3)*c(4)*c(5)*c(6)*c(7);
    fk(1,2)   = c(1)*c(4)*s(2)*s(6)*s(7)-c(1)*c(7)*s(2)*s(4)*s(5)-c(3)*c(5)*c(7)*s(1)+c(4)*c(7)*s(1)*s(3)*s(5)+c(3)*c(6)*s(1)*s(5)*s(7)+s(1)*s(3)*s(4)*s(6)*s(7)-c(1)*c(2)*c(5)*c(7)*s(3)-c(1)*c(2)*c(3)*c(4)*c(7)*s(5)-c(1)*c(2)*c(3)*s(4)*s(6)*s(7)+c(1)*c(2)*c(6)*s(3)*s(5)*s(7)-c(1)*c(5)*c(6)*s(2)*s(4)*s(7)+c(4)*c(5)*c(6)*s(1)*s(3)*s(7)-c(1)*c(2)*c(3)*c(4)*c(5)*c(6)*s(7);
    fk(1,3)   = c(3)*s(1)*s(5)*s(6)-c(6)*s(1)*s(3)*s(4)-c(1)*c(4)*c(6)*s(2)+c(1)*c(2)*s(3)*s(5)*s(6)-c(1)*c(5)*s(2)*s(4)*s(6)+c(4)*c(5)*s(1)*s(3)*s(6)+c(1)*c(2)*c(3)*c(6)*s(4)-c(1)*c(2)*c(3)*c(4)*c(5)*s(6);
    fk(1,4)   = 0.39*c(1)*c(2)*c(3)*s(4)-0.39*c(1)*c(4)*s(2)-0.39*s(1)*s(3)*s(4)-0.4*c(1)*s(2)-0.088*c(1)*c(4)*c(6)*s(2)-0.088*c(6)*s(1)*s(3)*s(4)+0.088*c(3)*s(1)*s(5)*s(6)+0.088*c(1)*c(2)*s(3)*s(5)*s(6)-0.088*c(1)*c(5)*s(2)*s(4)*s(6)+0.088*c(4)*c(5)*s(1)*s(3)*s(6)+0.088*c(1)*c(2)*c(3)*c(6)*s(4)-0.088*c(1)*c(2)*c(3)*c(4)*c(5)*s(6);
    fk(2,1)   = c(1)*c(3)*c(5)*s(7)-c(2)*c(5)*s(1)*s(3)*s(7)-c(1)*c(4)*s(3)*s(5)*s(7)-c(4)*c(7)*s(1)*s(2)*s(6)+c(1)*c(7)*s(3)*s(4)*s(6)-s(1)*s(2)*s(4)*s(5)*s(7)+c(1)*c(3)*c(6)*c(7)*s(5)+c(1)*c(4)*c(5)*c(6)*c(7)*s(3)-c(2)*c(3)*c(4)*s(1)*s(5)*s(7)+c(2)*c(3)*c(7)*s(1)*s(4)*s(6)-c(2)*c(6)*c(7)*s(1)*s(3)*s(5)+c(5)*c(6)*c(7)*s(1)*s(2)*s(4)+c(2)*c(3)*c(4)*c(5)*c(6)*c(7)*s(1);
    fk(2,2)   = c(1)*c(3)*c(5)*c(7)-c(7)*s(1)*s(2)*s(4)*s(5)+c(4)*s(1)*s(2)*s(6)*s(7)-c(1)*s(3)*s(4)*s(6)*s(7)-c(2)*c(5)*c(7)*s(1)*s(3)-c(1)*c(4)*c(7)*s(3)*s(5)-c(1)*c(3)*c(6)*s(5)*s(7)-c(2)*c(3)*c(4)*c(7)*s(1)*s(5)-c(1)*c(4)*c(5)*c(6)*s(3)*s(7)-c(2)*c(3)*s(1)*s(4)*s(6)*s(7)+c(2)*c(6)*s(1)*s(3)*s(5)*s(7)-c(5)*c(6)*s(1)*s(2)*s(4)*s(7)-c(2)*c(3)*c(4)*c(5)*c(6)*s(1)*s(7);
    fk(2,3)   = c(1)*c(6)*s(3)*s(4)-c(4)*c(6)*s(1)*s(2)-c(1)*c(3)*s(5)*s(6)+c(2)*s(1)*s(3)*s(5)*s(6)-c(5)*s(1)*s(2)*s(4)*s(6)+c(2)*c(3)*c(6)*s(1)*s(4)-c(1)*c(4)*c(5)*s(3)*s(6)-c(2)*c(3)*c(4)*c(5)*s(1)*s(6);
    fk(2,4)   = 0.39*c(1)*s(3)*s(4)-0.39*c(4)*s(1)*s(2)-0.4*s(1)*s(2)+0.39*c(2)*c(3)*s(1)*s(4)-0.088*c(4)*c(6)*s(1)*s(2)+0.088*c(1)*c(6)*s(3)*s(4)-0.088*c(1)*c(3)*s(5)*s(6)+0.088*c(2)*s(1)*s(3)*s(5)*s(6)-0.088*c(5)*s(1)*s(2)*s(4)*s(6)+0.088*c(2)*c(3)*c(6)*s(1)*s(4)-0.088*c(1)*c(4)*c(5)*s(3)*s(6)-0.088*c(2)*c(3)*c(4)*c(5)*s(1)*s(6);
    fk(3,1)   = c(2)*c(4)*c(7)*s(6)-c(5)*s(2)*s(3)*s(7)+c(2)*s(4)*s(5)*s(7)-c(3)*c(4)*s(2)*s(5)*s(7)+c(3)*c(7)*s(2)*s(4)*s(6)-c(6)*c(7)*s(2)*s(3)*s(5)-c(2)*c(5)*c(6)*c(7)*s(4)+c(3)*c(4)*c(5)*c(6)*c(7)*s(2);
    fk(3,2)   = c(2)*c(7)*s(4)*s(5)-c(5)*c(7)*s(2)*s(3)-c(2)*c(4)*s(6)*s(7)-c(3)*s(2)*s(4)*s(6)*s(7)+c(6)*s(2)*s(3)*s(5)*s(7)-c(3)*c(4)*c(7)*s(2)*s(5)+c(2)*c(5)*c(6)*s(4)*s(7)-c(3)*c(4)*c(5)*c(6)*s(2)*s(7);
    fk(3,3)   = c(2)*c(4)*c(6)+c(3)*c(6)*s(2)*s(4)+c(2)*c(5)*s(4)*s(6)+s(2)*s(3)*s(5)*s(6)-c(3)*c(4)*c(5)*s(2)*s(6);
    fk(3,4)   = 0.4*c(2)+0.39*c(2)*c(4)+0.088*c(2)*c(4)*c(6)+0.39*c(3)*s(2)*s(4)+0.088*c(3)*c(6)*s(2)*s(4)+0.088*c(2)*c(5)*s(4)*s(6)+0.088*s(2)*s(3)*s(5)*s(6)+-0.088*c(3)*c(4)*c(5)*s(2)*s(6)+0.31;
    fk(4,1)   = 0;
    fk(4,2)   = 0;
    fk(4,3)   = 0;
    fk(4,4)   = 1;
end


%% ************************************************************************
%% ************************************************************************

