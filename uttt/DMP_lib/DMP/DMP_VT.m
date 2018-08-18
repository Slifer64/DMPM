%% DMP class
%  Implements an 1-D DMP.
%  The DMP is driven by a canonical clock. It outputs the phase varialbe 
%  'x' which serves as a substitute for time. Typically, it evolves from 
%  x0=0 at t=0 to x_end=1, at t=tau, where tau is the total movement's 
%  duration. An example of a linear canonical clock is:
%     dx = -ax/tau
%  where x is the phase variable and ax the evolution factor. Other types 
%  of canonical clocks, such as exponential, can be used. However, keeping
%  a linear mapping between the phase variable 'x' and time 't' is more
%  intuitive.
%
%  The DMP has the in general the following form:
%
%     tau*dz = g1(x)*( a_z*(b_z*(g-y) - z ) + g2(x)*fs*f(x) + z_c
%     tau*dy = z + y_c;
%
%  Assuming y_c=z_c=0, we can write equivalently:
%     ddy = g1(x)*( a_z*(b_z*(g-y)-dy*tau) + 2(x)*fs*f(x) ) / tau^2;
%
%  where
%     tau: is scaling factor defining the duration of the motion
%     a_z, b_z: constants relating to a spring-damper system
%     fs: scaling of the forcing term (typically fs = g0-y0)
%     g: the goal-final position
%     y0: the initial position
%     x: the phase variable
%     y,dy,ddy: the position, velocity and accelaration of the motion
%     f(x): the forcing term defined by the normalized weighted sum of the 
%        kernel functions (gaussian kernels), i.e.:
%        f(x) = w'*Psi(x)/ sum(Psi(x));
%     g1(x): the gating factor of the spring-damper term
%     g2(x): the gating factor of non-linear forcing term
%

classdef DMP_VT < handle % : public DMP_
    properties
        N_kernels % number of kernels (basis functions)

        a_z % parameter 'a_z' relating to the spring-damper system
        b_z % parameter 'b_z' relating to the spring-damper system

        canClockPtr % handle (pointer) to the canonical clock
        shapeAttrGatingPtr % pointer to gating function for the shape attractor
        goalAttrGatingPtr % pointer to gating function for the goal attractor

        w % N_kernelsx1 vector with the weights of the DMP
        c % N_kernelsx1 vector with the kernel centers of the DMP
        h % N_kernelsx1 vector with the kernel stds of the DMP

        zero_tol % tolerance value used to avoid divisions with very small numbers

        a_s % scaling factor to ensure smaller changes in the accelaration to improve the training

        % training params
        trainMethod % training method for weights of the DMP forcing term

        lambda % forgetting factor in recursive training methods
        P_cov % Initial value of covariance matrix in recursive training methods

    end

    methods
        %% DMP_VT constructor
        %  @param[in] N_kernels: the number of kernels
        %  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
        %  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
        %  @param[in] canClockPtr: Pointer to a DMP canonical system object.
        %  @param[in] shapeAttrGatingPtr: Pointer to gating function for the shape attractor.
        %  @param[in] goalAttrGatingPtr: Pointer to gating function for the goal attractor.
        %  @param[in] kernelStdScaling: Scales the std of each kernel (optional, default = 1.0).
        %  @param[in] extraArgName: Names of extra arguments (optional, default = []).
        %  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
        function dmp = DMP_VT(N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue)

            if (nargin < 6)
                return;
            else
                if (nargin < 7), kernelStdScaling=1.0; end
                if (nargin < 8)
                    extraArgName = [];
                    extraArgValue = [];
                end
                dmp.init(N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue);
            end

        end


        %% Initializes the DMP
        %  @param[in] N_kernels: the number of kernels
        %  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
        %  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
        %  @param[in] canClockPtr: Pointer to a DMP canonical system object.
        %  @param[in] shapeAttrGatingPtr: Pointer to gating function for the shape attractor.
        %  @param[in] goalAttrGatingPtr: Pointer to gating function for the goal attractor.
        %  @param[in] kernelStdScaling: Scales the std of each kernel (optional, default = 1).
        %  @param[in] extraArgName: Names of extra arguments (optional, default = []).
        %  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
        function init(dmp, N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue)

            if (nargin < 8), kernelStdScaling=1.0; end
            if (nargin < 9)
                extraArgName = [];
                extraArgValue = [];
            end

            DMP_init(dmp, N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue);
            dmp.b_z = 0;
            
            dmp.zero_tol = 1e-30;
            
        end


        %% Sets the centers for the kernel functions of the DMP according to the canonical system
        function setCenters(dmp)

            DMP_setCenters(dmp);

        end


        %% Sets the standard deviations for the kernel functions  of the DMP
        %  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
        %  @param[in] kernelStdScaling: Scales the std of each kernel by 'kernelStdScaling' (optional, default = 1.0).
        function setStds(dmp, kernelStdScaling)

            if (nargin < 2), kernelStdScaling=1.0; end
            DMP_setStds(dmp, kernelStdScaling);

        end


        %% Trains the DMP
        %  @param[in] Time: Row vector with the timestamps of the training data points.
        %  @param[in] yd_data: Row vector with the desired potition.
        %  @param[in] dyd_data: Row vector with the desired velocity.
        %  @param[in] ddyd_data: Row vector with the desired accelaration.
        %  @param[in] y0: Initial position.
        %  @param[in] g: Target-goal position.
        %
        %  \note The timestamps in \a Time and the corresponding position,
        %  velocity and acceleration data in \a yd_data, \a dyd_data and \a
        %  ddyd_data need not be sequantial in time.
        function [train_error, F, Fd] = train(dmp, Time, yd_data, dyd_data, ddyd_data, y0, g)

            [train_error, F, Fd] = DMP_train(dmp, Time, yd_data, dyd_data, ddyd_data, y0, g);

        end
        
        function [train_error, F_data, Fd] = trainMulti(dmp, Time_data, Yd_data, dYd_data, ddYd_data)

            N_demos = length(Time_data);
            x_data = [];
            s_data = [];
            Psi_data = [];
            Fd_data = [];
            tau_mean = 0.0;
            for k=1:N_demos
                Time = Time_data{k};
                yd_data = Yd_data{k};
                dyd_data = dYd_data{k};
                ddyd_data = ddYd_data{k};
                
                y0 = yd_data(1);
                g = yd_data(end);

                dmp.canClockPtr.setTau(Time(end));
                tau_mean = tau_mean + Time(end);
                
                n_data = length(Time);

                x = zeros(1, n_data);
                s = zeros(1, n_data);
                Fd = zeros(1,n_data);
                Psi = zeros(dmp.N_kernels, n_data);
                for i=1:n_data
                    x(i) = dmp.phase(Time(i));
                    s(i) = dmp.forcingTermScaling(y0, g) * dmp.shapeAttrGating(x(i));
                    Fd(i) = dmp.calcFd(x(i), yd_data(i), dyd_data(i), ddyd_data(i), y0, g);
                    Psi(:,i) = dmp.kernelFunction(x(i));
                end
                
                x_data = [x_data x];
                s_data = [s_data s];
                Psi_data = [Psi_data Psi];
                Fd_data = [Fd_data Fd];
            end
            
            tau_mean = tau_mean/N_demos;
            dmp.canClockPtr.setTau(tau_mean);

            trainMethod = dmp.trainMethod;
            if (strcmpi(trainMethod,'LWR'))

                dmp.w = LWR(Psi_data, s_data, Fd_data, dmp.zero_tol);

            elseif (strcmpi(trainMethod,'RLWR'))

                dmp.w = RLWR(Psi_data, s_data, Fd_data, dmp.lambda, dmp.P_rlwr);

            elseif (strcmpi(trainMethod,'LS'))

                dmp.w = normKernelLS(Psi_data, s_data, Fd_data, dmp.zero_tol);

            else
                error('Unsopported training method ''%s''', trainMethod);
            end

            train_error = -1;
%             F_data = zeros(size(Fd_data));
%             for i=1:size(F_data,2)
%                 F_data(i) = dmp.learnedForcingTerm(x(i), y0, g);
%             end
% 
% 
%             train_error = norm(F_data-Fd)/length(F_data);

        end


        %% Sets the high level training parameters of the DMP
        %  @param[in] trainMethod: Method used to train the DMP weights.
        %  @param[in] extraArgName: Names of extra arguments (optional, default = []).
        %  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
        %
        %  \remark The extra argument names can be the following:
        %  'lambda': Forgetting factor for recursive training methods.
        %  'P_cov': Initial value of the covariance matrix for recursive training methods.
        function setTrainingParams(dmp, trainMethod, extraArgName, extraArgValue)

            if (nargin < 3)
                extraArgName = [];
                extraArgValue = [];
            end
            DMP_setTrainingParams(dmp, trainMethod, extraArgName, extraArgValue);

        end


        %% Updates the DMP weights using RLWR (Recursive Locally Weighted Regression)
        %  @param[in] dmp: DMP object.
        %  @param[in] x: The phase variable.
        %  @param[in] y: Position.
        %  @param[in] dy: Velocity.
        %  @param[in] ddy: Acceleration.
        %  @param[in] y0: Initial position.
        %  @param[in] g: Goal position.
        %  @param[in,out] P: \a P matrix of RLWR.
        %  @param[in] lambda: Forgetting factor.
        function [Sigma_w] = update_weights_with_RLWR(dmp, x, Ferr, y0, g, Sigma_w, lambda)
            
            s = dmp.forcingTermScaling(y0, g);
            psi = dmp.kernelFunction(x);
            
            P = diag(Sigma_w);

            % error = Fd - dmp.w*s;
            error = Ferr;

            P_prev = P;
            
            P = (P - (P.^2.*s.^2) ./ (lambda./psi + P.*s.^2)) / lambda;
            
            ind = P>P_prev;
            P(ind) = P_prev(ind);
            
            dmp.w = dmp.w + psi.*P.*s.*error; 
            
            Sigma_w = diag(P);

        end
        
        function [Sigma_w] = update_weights_with_KF(dmp, x, Ferr, y0, g, Sigma_w, sigma_noise)
            
            psi = dmp.kernelFunction(x);
            Psi = psi / (sum(psi) + dmp.zero_tol);
            
            K = Sigma_w*Psi*inv(sigma_noise + Psi'*Sigma_w*Psi);
            
            dmp.w = dmp.w + K*Ferr;
            Sigma_w = Sigma_w - K*(Sigma_w*Psi)';

        end
        
        function [Sigma_w] = update_weights_with_RLS(dmp, x, Ferr, y0, g, Sigma_w, lambda)

            psi = dmp.kernelFunction(x);
            Psi = psi / (sum(psi) + dmp.zero_tol);
            
            K = Sigma_w*Psi*inv(lambda + Psi'*Sigma_w*Psi);
            
%             Sigma_w_prev = Sigma_w;
            
            dmp.w = dmp.w + K*Ferr;
            Sigma_w = (1/lambda) * (Sigma_w - K*(Sigma_w*Psi)');
            
%             ind = Sigma_w>Sigma_w_prev;
%             Sigma_w(ind) = Sigma_w_prev(ind);

        end


        %% Calculates the desired values of the scaled forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] y: Position.
        %  @param[in] dy: Velocity.
        %  @param[in] ddy: Acceleration.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] Fd: Desired value of the scaled forcing term.
        function Fd = calcFd(dmp, x, y, dy, ddy, y0, g)

            v_scale = dmp.get_v_scale();
            Fd = (ddy*v_scale^2 - dmp.goalAttractor(x, y, v_scale*dy, g));

        end
        
        
        %% Returns the learned forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function learnForcTerm = learnedForcingTerm(dmp, x, y0, g)

            learnForcTerm = DMP_learnedForcingTerm(dmp, x, y0, g);
            
        end


        %% Returns the forcing term of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[out] f: The normalized weighted sum of Gaussians.
        function f = forcingTerm(dmp,x)

            f = DMP_forcingTerm(dmp,x);

        end


        %% Returns the scaling factor of the forcing term.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function f_scale = forcingTermScaling(dmp, y0, g)

            f_scale = 1.0;

        end
        
        
        %% Returns the shape attractor gating factor.
        %  @param[in] x: The phase variable.
        function sAttrGat = shapeAttrGating(dmp, x)

            sAttrGat = 1.0; % DMP_shapeAttrGating(dmp,x);

        end
        
        
        %% Returns the goal attractor gating factor.
        %  @param[in] x: The phase variable.
        function gAttrGat = goalAttrGating(dmp, x)

            gAttrGat = 1.0; % DMP_goalAttrGating(dmp,x);

        end


        %% Returns the goal attractor of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[in] y: \a y state of the DMP.
        %  @param[in] z: \a z state of the DMP.
        %  @param[in] g: Goal position.
        %  @param[out] goal_attr: The goal attractor of the DMP.
        function goal_attr = goalAttractor(dmp, x, y, z, g)

            g_attr_gating = dmp.goalAttrGating(x);
            goal_attr = g_attr_gating * DMP_goalAttractor(dmp, y, z, g);

        end


        %% Returns the shape attractor of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] shape_attr: The shape_attr of the DMP.
        function shape_attr = shapeAttractor(dmp, x, y0, g)
            
            s_attr_gating = dmp.shapeAttrGating(x);
            shape_attr = s_attr_gating * DMP_shapeAttractor(dmp, x, y0, g);

        end
        
        
        %% Returns the phase variable.
        %  @param[in] t: The time instant.
        %  @param[out] x: The phase variable for time 't'.
        function x = phase(dmp, t)
            
            x = DMP_phase(dmp, t);

        end
        
        
        %% Returns the derivative of the phase variable.
        %  @param[in] x: The phase variable.
        %  @param[out] dx: The derivative of the phase variable.
        function dx = phaseDot(dmp, x)
            
            dx = DMP_phaseDot(dmp, x);

        end


        %% Returns the derivatives of the DMP states
        %  @param[in] x: phase variable.
        %  @param[in] y: \a y state of the DMP.
        %  @param[in] z: \a z state of the DMP.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[in] y_c: coupling term for the dynamical equation of the \a y state.
        %  @param[in] z_c: coupling term for the dynamical equation of the \a z state.
        %  @param[out] dy: derivative of the \a y state of the DMP.
        %  @param[out] dz: derivative of the \a z state of the DMP.
        %  @param[out] dx: derivative of the phase variable of the DMP.
        function [dy, dz, dx] = getStatesDot(dmp, x, y, z, y0, g, y_c, z_c)
  
            if (nargin < 8), z_c=0.0; end
            if (nargin < 7), y_c=0.0; end

            [dy, dz, dx] = DMP_getStatesDot(dmp, x, y, z, y0, g, y_c, z_c);

        end


        %% Returns a column vector with the values of the kernel functions of the DMP
        %  @param[in] x: phase variable
        %  @param[out] psi: column vector with the values of the kernel functions of the DMP
        function psi = kernelFunction(dmp,x)

            psi = DMP_gaussianKernel(dmp,x);
            
%             psi(psi<1e-20) = 0.0;

        end


        %% Returns the scaling factor of the DMP
        %  @param[out] v_scale: The scaling factor of the DMP.
        function v_scale = get_v_scale(dmp)

            v_scale = DMP_get_v_scale(dmp);

        end


        %% Returns the time cycle of the DMP
        %  @param[out] tau: The time duration of the DMP.
        function tau = getTau(dmp)

            tau = DMP_getTau(dmp);

        end
        
        %% Returns DMP's number of kernels
        %  @param[out] numKernels: The number of kernels in the DMP
        function numKernels = getNumKernels(dmp)

            numKernels = length(dmp.w);

        end

        %% Parse extra arguments of the DMP
        %  @param[in] extraArgName: Names of extra arguments.
        %  @param[in] extraArgValue: Values of extra arguemnts.
        function parseExtraArgs(dmp, extraArgName, extraArgValue)


        end

    end
end
