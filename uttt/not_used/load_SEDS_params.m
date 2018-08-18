function [Priors, Mu, Sigma] = load_SEDS_params(file)

fid = fopen(file);


[tmp] = fscanf(fid,'%d');
d = tmp(1)/2;
K = tmp(2);

Priors = fscanf(fid,'%f',K);

tmp = fscanf(fid,'%f',2*d*K)';
Mu = reshape(tmp,2*d,K);

tmp = fscanf(fid,'%f',2*d*2*d*K);
Sigma = reshape(tmp,2*d,2*d,K);

end