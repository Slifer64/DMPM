function plot_linear_rot_velocities(T, V, V_sim)

    figure('Name','velocities plot','NumberTitle','off');

    subplot(2,2,1);
    plot(T,V(1:3,:), T,V_sim(1:3,:));
    legend('v_x','v_y','v_z','v_x_s_i_m','v_y_s_i_m','v_z_s_i_m');

    subplot(2,2,2);
    plot(T,V(4:6,:), T,V_sim(4:6,:));
    legend('ù_x','ù_y','ù_z','ù_x_s_i_m','ù_y_s_i_m','ù_z_s_i_m');

    subplot(2,2,3);
    plot(T,V(1:3,:) - V_sim(1:3,:));
    legend('v_x-v_x_s_i_m','v_y-v_y_s_i_m','v_z-v_z_s_i_m');

    subplot(2,2,4);
    plot(T,V(4:6,:) - V_sim(4:6,:));
    legend('ù_x-ù_x_s_i_m','ù_y-ù_y_s_i_m','ù_z-ù_z_s_i_m');
end
