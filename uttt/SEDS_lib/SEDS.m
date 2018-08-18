classdef SEDS < handle
   properties
	Priors % Eigen::VectorXd
	Mu     % std::vector<Eigen::VectorXd, Eigen::aligned_allocator<Eigen::VectorXd> > 
	Sigma  % std::vector<Eigen::MatrixXd, Eigen::aligned_allocator<Eigen::MatrixXd> >
   end
   methods
      function seds = SEDS()
		seds_params = load('learning_params','Priors','Mu','Sigma');
		if (~isempty(seds_params))
			seds.Priors = seds_params.Priors;
			seds.Mu = cell(size(seds_params.Mu,2),1);
            for k=1:length(seds.Mu)
                seds.Mu{k} = seds_params.Mu(:,k);
            end
            
			seds.Sigma = cell(size(seds_params.Sigma,3),1);
            for k=1:length(seds.Sigma)
                seds.Sigma{k} = seds_params.Sigma(:,:,k);
            end
		end
      end
	  
	  function r = gaussPDF(seds, X, Mu, Sigma)
		nVar = size(X,1); %X.rows();
		nData = size(X,2); %X.cols();

		X_temp = X' - repmat(Mu', nData, 1); 
		prob = exp( -0.5*sum((X_temp / Sigma) .* X_temp, 2) );

		r = prob/sqrt( (2*pi)^(nVar)*(abs(det(Sigma)) + realmin));
	  end

	  function Y = get_seds_output(seds, X)
		nData = size(X,2); % X.cols();
		nVar = size(X,1); % X.rows();
		
		Y = zeros(nVar, nData);
		
		nStates = length(seds.Mu);

		h = zeros(nData,nStates);
		A = cell(nStates,1);

		for k=1:nStates
			h(:,k) = seds.Priors(k) * seds.gaussPDF(X, seds.Mu{k}(1:nVar), seds.Sigma{k}(1:nVar,1:nVar));
			A{k} = seds.Sigma{k}(nVar+1:end,1:nVar) / seds.Sigma{k}(1:nVar,1:nVar);
		end
		h = h ./ repmat(sum(h,2) + realmin, 1, nStates);

		for i=1:nData
			for k=1:nStates
				Y(:,i) = Y(:,i) + h(i,k) * ( A{k} * (X(:,i)-seds.Mu{k}(1:nVar)) + seds.Mu{k}(nVar+1:end) );
			end
		end
		
	  end
	  
	  %function V = get_V(seds, X)
	  %	V = seds.get_seds_output(X);
	  %end

	  function V = get_V(seds, T)
		X = seds.transform_to_sedsParams(T);
		V = seds.get_seds_output(X);
	  end
	  
	  function X = transform_to_sedsParams(seds, T)
		Q = rotm2quat(T(1:3,1:3))';
		n = Q(1);   nd = 1;
		e = Q(2:4); ed = zeros(3,1);
		e0 = -(n*ed - nd*e - cross(ed,e));
		
		%e0 = Q(2:4);

		X = [T(1:3,4); e0];	
	  end

	  function T = sedsParams_to_transform(seds, X)
	    T = eye(4);
		T(1:3,4) = X(1:3);

		% assuming theta:[-pi,pi] -> n=cos(theta/2) >= 0
		n = sqrt(1-X(4:6)'*X(4:6));
		Q = [n; X(4); X(5); X(6)];

		T(1:3, 1:3) = quat2rotm(Q);
	  end
	  
	  function r = load_sedsParams(seds, filename)
		[fid, errmsg] = fopen(filename,'r');
		if (fid == -1)
			warning(errmsg);
			r = false;
			fclose(fid);
			return;
		end

		d = fscanf(fid,'%i');
		K = fscanf(fid,'%i');

		d = d/2;

		seds.Priors = fscanf(fid,'%f',K);
		
		seds.Mu = cell(K,1);
		for k=1:K
			seds.Mu{k} = fscanf(fid,'%f',2*d);
		end

		seds.Sigma = cell(K,1);
		for k=1:K
			seds.Sigma{k} = fscanf(fid,'%f',[2*d, 2*d]);
		end

		fclose(fid);
		r = true;
	  end

	  function r = save_sedsParams(seds, filename)
		[fid, errmsg] = fopen(filename,'w');
		if (fid == -1)
			warning(errmsg);
			r = false;
			fclose(fid);
			return;
		end

		n = length(seds.Mu{1});
		K = length(seds.Priors);

		fprintf(fid,'%i ',n);
		fprintf(fid,'%i\n',K);

		fprintf(fid,'%f\n',seds.Priors);

		for k=1:K
			fprintf(fid,'%f ',seds.Mu{k});
			fprintf(fid,'\n');
		end
		
		for k=1:K
			fprintf(fid,'%f ',seds.Sigma{k});
			fprintf(fid,'\n');
		end

		fclose(fid);
		r = true;
	  end
   end
end




