function convert_config_yaml_to_cpp(config_filename, out_filename)

% clc;
% close all;
% clear;

% config_filename = 'config.yml';
% out_filename = 'cmd_args';

cmd_args_h_filename = [out_filename '.h'];
cmd_args_cpp_filename = [out_filename '.cpp'];

%% *******************************
%% ****   Parse yaml file    *****
%% *******************************

fprintf('Parsing %s ...\n', config_filename);

[fid, err_msg] = fopen(config_filename,'r');
if (fid < 0)
    error(err_msg);
end

var_name = cell(1);
var_val = cell(1);
var_type = cell(1);
var_comment = cell(1);
i = 0;

while (true)
    line = fgets(fid);
    
    if (line == -1), break; end
    
%     line
    
    k = strfind(line,':');
    
    if (~isempty(k))
        i = i + 1;
        var_name{i} = strtrim(line(1:k-1));
        line = line(k+1:end);
        
        k = strfind(line,'#');
        
        if (~isempty(k))
            var_val{i} = strtrim(line(1:k-1));
            var_comment{i} = strtrim(line(k+1:end));
        else
            var_val{i} = strtrim(line);
            var_comment{i} = [];
        end
        
        [num, is_num] = str2num(var_val{i});
        if (strcmpi(var_val{i},'true') || strcmpi(var_val{i},'false'))
            var_type{i} = 'bool';
        elseif (var_val{i}(1) ~= '"')
            if (isempty(strfind(var_val{i},'.')))
                var_type{i} = 'int';
            else
                var_type{i} = 'double';
            end
        else
            var_type{i} = 'std::string';
        end     
    else
       continue; 
    end
    
    
%     var_names{i}
%     var_val{i} 
%     var_type{i}
%     var_comment{i} 
%     
%     pause
    
end

fclose(fid);


%% *********************************
%% ****   Write header file    *****
%% *********************************

fprintf('Writing to %s ...\n', cmd_args_h_filename);

[fid, err_msg] = fopen(cmd_args_h_filename,'w');
if (fid < 0)
    error(err_msg);
end


fprintf(fid, '#ifndef CMD_ARGS_H\n');
fprintf(fid, '#define CMD_ARGS_H\n\n');

fprintf(fid, '#include <iostream>\n');
fprintf(fid, '#include <cstdlib>\n');
fprintf(fid, '#include <string>\n');
fprintf(fid, '#include <fstream>\n');
fprintf(fid, '#include <ros/ros.h>\n\n');

fprintf(fid, 'struct CMD_ARGS\n{\n');

tab_space = ' ';

for i=1:length(var_name)
    fprintf(fid, '%s %s %s; ',tab_space, var_type{i}, var_name{i});
    if (~isempty(var_comment{i}))
        fprintf(fid, '%s',['// ' var_comment{i}]);
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n');

fprintf(fid, '%s CMD_ARGS();\n',tab_space);
fprintf(fid, '%s bool parse_cmd_args();\n',tab_space);
fprintf(fid, '%s void print(std::ostream &out=std::cout) const;\n',tab_space);
fprintf(fid, '};\n\n');

fprintf(fid, '#endif // CMD_ARGS_H\n');

fclose(fid);


%% ******************************
%% ****   Write cpp file    *****
%% ******************************

fprintf('Writing to %s ...\n', cmd_args_cpp_filename);

[fid, err_msg] = fopen(cmd_args_cpp_filename,'w');
if (fid < 0)
    error(err_msg);
end

fprintf(fid, '#include <%s>\n\n', cmd_args_h_filename);

fprintf(fid, 'CMD_ARGS::CMD_ARGS() {}\n\n');

fprintf(fid, 'bool CMD_ARGS::parse_cmd_args()\n');
fprintf(fid, '{\n');
fprintf(fid, '%s ros::NodeHandle nh_ = ros::NodeHandle("~");\n\n', tab_space);

for i=1:length(var_name)
    fprintf(fid, '%s if (!nh_.getParam("%s", %s)) %s = %s;\n', ...
        tab_space, var_name{i}, var_name{i}, var_name{i}, var_val{i});
end

fprintf(fid, '\n}\n\n');

fprintf(fid, 'void CMD_ARGS::print(std::ostream &out) const\n');
fprintf(fid, '{\n');

for i=1:length(var_name)
    fprintf(fid, '%s out << "%s: " << %s << %s;\n', ...
        tab_space, var_name{i}, var_name{i}, '"\n"');
end

fprintf(fid, '\n}\n\n');


fclose(fid);


end