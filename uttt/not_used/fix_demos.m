function fix_demos()

clc; 
close all;
clear;

load demos.mat demos;

demos_to_fix = [{'111'}, {'121'}, {'122'}, {'131'}, {'132'}, {'141'}, {'143'}, {'144'}];

cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

DemosLabels = demos(:,end);
for k=1:length(demos_to_fix)
   i = find(cellfun(cellfind(demos_to_fix{k}),DemosLabels));
   temp = demos(i,1:end-1);
   demos(i,1:end-1) = demos(i+1,1:end-1);
   demos(i+1,1:end-1) = temp;
end



for k=1:size(demos,1)
    T = demos{k,1};
    Pos = demos{k,3};
    Quat = demos{k,4};
    demoLabel = demos{k,7};
    
    fprintf('Processing demo %d: %s\n',k,demoLabel);
    Axang = quat2axang(Quat')';
    write_wrl(['wrl_files/' demoLabel], Pos*10, Axang, T);
end

save demos.mat demos;

end

