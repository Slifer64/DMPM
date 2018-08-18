function write_sim_results_to_wrl(type,demos,T,sim_results,T_sim)


d = size(demos{1},1)/2;

for k=1:length(sim_results)
    [demo_data_pos, demo_data_axisAngle] = convertVar2Data(demos{k}(1:d,:));
    t_demo = T{k}';%((1:size(data_pos,2))-1)/size(data_pos,2)*5;
    fprintf([type ':Demo %d\n'],k);
    write_wrl(['wrl_files/' type '_Demo' num2str(k)], demo_data_pos*10, demo_data_axisAngle, t_demo);
    
    [sim_data_pos, sim_data_axisAngle] = convertVar2Data(sim_results{k}(1:d,:));
    t_sim = T_sim{k};%((1:size(data_pos,2))-1)/size(data_pos,2)*5;
%     fprintf([type ':Sim %d\n'],k);
%     write_wrl(['wrl_files/' type '_Sim' num2str(k)], sim_data_pos*10, sim_data_axisAngle, t_sim);
    
    %downsample sim data
    d_f = 3;
    t_sim = t_sim(1:d_f:end);
    sim_data_pos = sim_data_pos(:,1:d_f:end);
    sim_data_axisAngle = sim_data_axisAngle(:,1:d_f:end);
    
    %*************************************************************
    %*******     Create wrl for comparing demo_vs_sim     ********
    %*************************************************************

    %% open file
    fprintf([type ':writing wrl Demo_vs_Sim_%d\n'],k);
    
    in_filename = 'compare_demo_sim.txt';
    out_filename = ['wrl_files/' type '_compare_demo_sim_' num2str(k) '.wrl'];
    fid = fopen(in_filename,'r+');
    str_file = fscanf(fid,'%c');
    fclose(fid);
    
    t_duration = 3;
    t_demo = t_demo/t_demo(end) * t_duration;
    t_sim = t_sim/t_sim(end) * t_duration;
    
    %demo_data_pos = [demo_data_pos repmat(demo_data_pos(:,end),1,length(t_sim) - length(t_demo))];
    %demo_data_axisAngle = [demo_data_axisAngle repmat(demo_data_axisAngle(:,end),1,length(t_sim) - length(t_demo))];

    demo_data_pos = demo_data_pos*10;
    sim_data_pos = sim_data_pos*10;
    
    %% define the duration of the movement
    str_file = regexprep(str_file,'#MovementDuration',sprintf(num2str(ceil(t_sim(end)))));

    %% Interpolate position and rotation for Demo-Coordinate-System
    %interpolate desired rotation
    str_file = rotation_interpolation(demo_data_axisAngle,t_demo,'#demo_coord_sys_init_rotation','#demo_Coord_Sys_rotkey','#demo_Coord_Sys_value_rotkey',str_file);

    %interpolate desired position (using cm instead of meters)
    str_file = position_interpolation(demo_data_pos,t_demo,'#demo_coord_sys_init_translation','#demo_Coord_Sys_poskey','#demo_Coord_Sys_value_poskey',str_file);

    %% Interpolate position and rotation for Sim-Coordinate-System
    %interpolate desired rotation
    str_file = rotation_interpolation(sim_data_axisAngle,t_sim,'#sim_coord_sys_init_rotation','#sim_Coord_Sys_rotkey','#sim_Coord_Sys_value_rotkey',str_file);

    %interpolate desired position (using cm instead of meters)
    str_file = position_interpolation(sim_data_pos,t_sim,'#sim_coord_sys_init_translation','#sim_Coord_Sys_poskey','#sim_Coord_Sys_value_poskey',str_file);

    %% save wrl file
    fid2=fopen(out_filename,'wb');
    fwrite(fid2,str_file);
    fclose(fid2);
    %-------------------------------------------------------------------------
end

end

function [str_file] = position_interpolation(q,t,initial_key,key,valueKey,str_file)

%----------------Initial Position------------------------
str_file=regexprep(str_file,initial_key,sprintf([num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1))]));
%--------------------------------------------------------

TOTALTIME = t(end);
KeyForAll = t;
NorKeyForAll = KeyForAll/TOTALTIME;

%-------------Interpolate Desired Position-------------
str_file=regexprep(str_file,key,sprintf([ num2str(NorKeyForAll(1)) '#NextValue' ])    );
for i=2:length(KeyForAll)
    str_file=regexprep(str_file,'#NextValue',sprintf([', ' num2str(NorKeyForAll(i)) '#NextValue'  ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');

str_file=regexprep(str_file,valueKey,sprintf([num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1)) '#NextValue'  ])    );
for i=2:length(KeyForAll)
    str_file=regexprep(str_file,'#NextValue',sprintf([' ,\n'  num2str(q(1,i)) ' ' num2str(q(2,i)) ' ' num2str(q(3,i)) '#NextValue'  ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');
%--------------------------------------------------------

end


function [str_file] = rotation_interpolation(q,t,initial_key,key,valueKey,str_file)

rot_axon = [num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1))];
%----------------Initial Rotation------------------------
str_file=regexprep(str_file,initial_key,sprintf([rot_axon ' ' num2str(q(4,1))]));
%--------------------------------------------------------

TOTALTIME = t(end);
KeyForAll = t;
NorKeyForAll = KeyForAll/TOTALTIME;

%-------------Interpolate Desired Rotation-------------
str_file=regexprep(str_file,key,sprintf([ num2str(NorKeyForAll(1)) '#NextValue' ])    );
for i=2:length(KeyForAll)
    str_file=regexprep(str_file,'#NextValue',sprintf([', ' num2str(NorKeyForAll(i)) '#NextValue'  ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');

rot_axon = [num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1))];
str_file=regexprep(str_file,valueKey,sprintf([rot_axon ' ' num2str(q(4,1)) '#NextValue' ]));
for i=2:length(KeyForAll)
    rot_axon = [num2str(q(1,i)) ' ' num2str(q(2,i)) ' ' num2str(q(3,i))];
    str_file=regexprep(str_file,'#NextValue',sprintf([',\n' rot_axon ' ' num2str(q(4,i)) '#NextValue' ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');
%--------------------------------------------------------

end