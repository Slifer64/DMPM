function write_wrl(timeStamp, pos_data, axisAngle_data, T)

    %***********************************
    %*******     Create wrl     ********
    %***********************************

    %% open file
    %disp('writing wrl...')

    in_filename = 'coordinate_system.txt';
    out_filename = [timeStamp '_coordinate_system.wrl'];
    fid = fopen(in_filename,'r+');
    str_file = fscanf(fid,'%c');
    fclose(fid);

    %% define the duration of the movement
    str_file = regexprep(str_file,'#MovementDuration',sprintf(num2str(ceil(T(end)))));
        
    %% Interpolate position and rotation for Coordinate-System
    %interpolate desired rotation
    str_file = rotation_interpolation(axisAngle_data,T,'#coord_sys_init_rotation','#Coord_Sys_rotkey','#Coord_Sys_value_rotkey',str_file);

    %interpolate desired position (using cm instead of meters)
    str_file = position_interpolation(pos_data,T,'#coord_sys_init_translation','#Coord_Sys_poskey','#Coord_Sys_value_poskey',str_file);

    %% save wrl file
    fid2=fopen(out_filename,'wb');
    fwrite(fid2,str_file);
    fclose(fid2);
    %-------------------------------------------------------------------------


end



