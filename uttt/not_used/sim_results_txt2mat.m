function sim_results_txt2mat()

%% Convert train data
fid = fopen('train_sim_results.txt');

n_demos = fscanf(fid,'%d',1);
d = fscanf(fid,'%d',1);
nVar = 2*d;

train_demos_sim = cell(n_demos,1);
train_V_sim = cell(n_demos,1); 
train_T_sim = cell(n_demos,1);

for k=1:n_demos
	n_points = fscanf(fid,'%d',1);
	train_T_sim{k} = fscanf(fid,'%f',n_points);
	train_demos_sim{k} = zeros(nVar,n_points);
    train_V_sim{k} = zeros(6,n_points);
    for j=1:n_points
        train_demos_sim{k}(:,j) = fscanf(fid,'%f',nVar);
        train_V_sim{k}(:,j) = fscanf(fid,'%f',6);
    end
end

fclose(fid);
    
save train_sim_results.mat train_demos_sim train_T_sim train_V_sim


%% Convert test data
fid = fopen('test_sim_results.txt');

n_demos = fscanf(fid,'%d',1);
d = fscanf(fid,'%d',1);
nVar = 2*d;

test_demos_sim = cell(n_demos,1);
test_V_sim = cell(n_demos,1); 
test_T_sim = cell(n_demos,1);

for k=1:n_demos
	n_points = fscanf(fid,'%d',1);
	test_T_sim{k} = fscanf(fid,'%f',n_points);
	test_demos_sim{k} = zeros(nVar,n_points);
    test_V_sim{k} = zeros(6,n_points);
    for j=1:n_points
        test_demos_sim{k}(:,j) = fscanf(fid,'%f',nVar);
        test_V_sim{k}(:,j) = fscanf(fid,'%f',6);
    end
end

fclose(fid);
    
save test_sim_results.mat test_demos_sim test_T_sim test_V_sim


end