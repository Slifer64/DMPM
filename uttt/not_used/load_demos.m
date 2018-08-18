function [Data, index] = load_demos(filename)

fid = fopen(filename);

n_demos = fscanf(fid,'%d',1);
nVar = fscanf(fid,'%d',1);
d = nVar/2;
demos = cell(1,n_demos);

for k=1:n_demos
    n_points = fscanf(fid,'%d',1);
    demos{k} = zeros(nVar,n_points);
    for i=1:nVar
        for j=1:n_points
            demos{k}(i,j) = fscanf(fid,'%f',1);
        end
    end
end

Data=[];
index = 1;
for i=1:length(demos)   
    Data = [Data demos{i}];
    index = [index size(Data,2)+1];
end

end

