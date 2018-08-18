function plot_pos_orient_errors(T, X, X_sim)

    figure('Name','position and orientation plot','NumberTitle','off');

    subplot(2,2,1);
    plot(T,X(1:3,:), T,X_sim(1:3,:));
    legend('x','y','z','x_s_i_m','y_s_i_m','z_s_i_m');

    subplot(2,2,2);
    plot(T,X(4:6,:), T,X_sim(4:6,:));
    legend('eo_1','eo_2','eo_3','eo_1_s_i_m','eo_2_s_i_m','eo_3_s_i_m');

    subplot(2,2,3);
    plot(T,X(1:3,:) - X_sim(1:3,:));
    legend('x-x_s_i_m','y-y_s_i_m','z-z_s_i_m');

    subplot(2,2,4);
    plot(T,X(4:6,:) - X_sim(4:6,:));
    legend('eo_1-eo_1_s_i_m','eo_2-eo_2_s_i_m','eo_2-eo_2_s_i_m');
end

