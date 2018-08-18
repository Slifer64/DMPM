function compare_dtw_demo_sim_results_with_wrl(wrl_label,T,Pos,Axang,Pos_sim,Axang_sim)
    
    %*************************************************************
    %*******     Create wrl for comparing demo_vs_sim     ********
    %*************************************************************

    %% open file
    %fprintf([wrl_label ':writing wrl...\n']);
    
    in_filename = 'compare_demo_sim.txt';
    out_filename = ['wrl_files/' wrl_label '.wrl'];
    fid = fopen(in_filename,'r+');
    str_file = fscanf(fid,'%c');
    fclose(fid);
    
    t_duration = 3;
    T = T/T(end) * t_duration;
    T_sim = T;

    Pos = Pos*10;
    Pos_sim = Pos_sim*10;
    
    %% define the duration of the movement
    str_file = regexprep(str_file,'#MovementDuration',sprintf(num2str(ceil(T_sim(end)))));

    %% Interpolate position and rotation for Demo-Coordinate-System
    %interpolate desired rotation
    str_file = rotation_interpolation(Axang,T,'#demo_coord_sys_init_rotation','#demo_Coord_Sys_rotkey','#demo_Coord_Sys_value_rotkey',str_file);

    %interpolate desired position (using cm instead of meters)
    str_file = position_interpolation(Pos,T,'#demo_coord_sys_init_translation','#demo_Coord_Sys_poskey','#demo_Coord_Sys_value_poskey',str_file);

    %% Interpolate position and rotation for Sim-Coordinate-System
    %interpolate desired rotation
    str_file = rotation_interpolation(Axang_sim,T_sim,'#sim_coord_sys_init_rotation','#sim_Coord_Sys_rotkey','#sim_Coord_Sys_value_rotkey',str_file);

    %interpolate desired position (using cm instead of meters)
    str_file = position_interpolation(Pos_sim,T_sim,'#sim_coord_sys_init_translation','#sim_Coord_Sys_poskey','#sim_Coord_Sys_value_poskey',str_file);

    %% save wrl file
    fid2=fopen(out_filename,'wb');
    fwrite(fid2,str_file);
    fclose(fid2);
    %-------------------------------------------------------------------------

end
