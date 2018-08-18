function bic = BIC_measure(demos,T)

Data = [];
for i=1:length(demos)
    Data = [Data demos{i}];
end

[Priors, Mu, Sigma] = load_SEDS_params('SEDS_params.txt');

bic = calc_BIC(Data,Priors,Mu,Sigma);

end

function bic = calc_BIC(Data,Priors,Mu,Sigma)

total_points = size(Data,2);
d = size(Data,1)/2;
K = length(Priors);

J = log_likelihood_cost_fun(Data,Priors,Mu,Sigma);

n_params = K*( 1 + 2*d + d*(2*d+1) );

fprintf('J cost: %g\n',total_points*J);
fprintf('Params cost: %g\n',n_params*log(total_points)/2);

bic = total_points*J + n_params*log(total_points)/2;

end