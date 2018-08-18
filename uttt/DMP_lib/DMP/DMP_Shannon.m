%% DMP Shannon class
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

classdef DMP_Shannon < handle % : public DMP
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
        P_cov% Initial value of covariance matrix in recursive training methods

        Freq_min % minimum allowable filter frequency to avoid instabilities with filtering
        Freq_max % filter out all frequencies beyond 'Freq_max'
        Wmin % minimum energy percent that must be retained after filtering
        P1_min % take all frequency components up to Freq_max with amplitude >= 'P1_min', even in the case that Wmin is satisfied
        
    end

    methods
        %% DMP constructor
        %  @param[in] N_kernels: the number of kernels
        %  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
        %  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
        %  @param[in] canClockPtr: Pointer to a DMP canonical system object.
        %  @param[in] shapeAttrGatingPtr: Pointer to gating function for the shape attractor.
        %  @param[in] goalAttrGatingPtr: Pointer to gating function for the goal attractor.
        %  @param[in] kernelStdScaling: Scales the std of each kernel (optional, default = 1.0).
        %  @param[in] extraArgName: Names of extra arguments (optional, default = []).
        %  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
        function dmp = DMP_Shannon(N_kernels, a_z, b_z, canClockPtr, shapeAttrGatingPtr, goalAttrGatingPtr, kernelStdScaling, extraArgName, extraArgValue)

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
            
%             dmp.a_s = 1.0;
        end


        %% Sets the centers for the kernel functions of the DMP according to the canonical system
        function setCenters(dmp)

            DMP_setCenters(dmp);

        end


        %% Sets the standard deviations for the kernel functions  of the DMP
        %  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
        %  @param[in] kernelStdScaling: Scales the variance of each kernel by 'kernelStdScaling' (optional, default = 1.0).
        function setStds(dmp, kernelStdScaling)

            if (nargin < 2), kernelStdScaling=1.0; end
            dmp.h = kernelStdScaling;

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
        %  ddyd_data MUST be sequantial in time and sampled with the same frequency.
        function [train_error, F, Fd] = train(dmp, Time, yd_data, dyd_data, ddyd_data, y0, g)

            tau = dmp.getTau();
            n_data = length(Time);
            x = zeros(1, n_data);
            s = zeros(1, n_data);
            Fd = zeros(1, n_data);
            for i=1:length(s)
                x(i) = dmp.phase(Time(i));
                s(i) = dmp.forcingTermScaling(y0, g) * dmp.shapeAttrGating(x(i));
                Fd(i) = dmp.calcFd(x(i), yd_data(i), dyd_data(i), ddyd_data(i), y0, g);
            end

            Ts = Time(2)-Time(1);
            Fs = 1/Ts;
            [f, P1, Y] = getSingleSidedFourier(Fd, Fs);

            %Freq_max = f(end);
            Freq_max = min([dmp.Freq_max, f(end)]);

            % find the maximum required frequency to get at least 'Wmin' percent of the
            % total signal's energy
          
            W = sum(P1(f<=Freq_max).^2);
           % W = sum(P1.^2);
            W_temp = 0;
            k = 0;
            
            while (W_temp < W*dmp.Wmin)
                k = k+1;
                W_temp = W_temp + P1(k)^2;
            end
            
%             W
%             W_all = sum(P1.^2)
%             W_temp
%             
%             W_temp/W_all

            Freq1 = f(k);
            fprintf('Frequency to get at least %.3f of the energy: Freq=%.3f Hz\n', dmp.Wmin, Freq1);


            while (k <= length(f))
                if (f(k) >= Freq_max)
                    break;
                end
                %               if (P1(k) > dmp.P1_min)
                %                 W_temp = W_temp + P1(k)^2;
                %               end
                if (P1(k) < dmp.P1_min)
                    break;
                end
                k = k+1;
            end
           
            Fmax = f(k);
            Fmax = min(dmp.Freq_max,Fmax);
            Fmax = max(dmp.Freq_min, Fmax);
            

            fprintf('Frequency after which the amplitude drops below %.3f: Freq=%.3f Hz\n', dmp.P1_min, Fmax);

            % ==> Filter the signal retaining at least 'Wmin' energy
            [but_filt_b, but_filt_a] = butter(6, Fmax/(Fs/2), 'low');
%             Fd_filt = filtfilt(but_filt_b, but_filt_a, Fd);
%             Fd_filt = filter(but_filt_b, but_filt_a, Fd);

%             n_ham_filter = min(round(n_data*0.01), 50);
            n_ham_filter = round(Fs/dmp.Freq_min);
            ham_filt_b = fir1(n_ham_filter, Fmax/(Fs/2), 'low');
            Fd_filt = filtfilt(ham_filt_b, 1, Fd);
%             Fd_filt = filter(ham_filt_b, 1, Fd);
            
            nf = length(ham_filt_b);
%             Fd_filt = [ones(1,nf)*Fd(1) zeros(1,n_data)];


%             Fd_filt2 = filtfilt(but_filt_b, but_filt_a, Fd);
            

%             figure;
%             
%             [hy,hx] = freqz(ham_filt_b,1);
%             hx = Fs*hx/(2*pi);
%             ham_dB = mag2db(abs(hy));
%             subplot(2,1,1);
%             plot(hx, ham_dB);
%             xlabel('f [$Hz$]', 'Interpreter','latex', 'FontSize',14);
%             ylabel('Magnitude ($dB$)', 'Interpreter','latex', 'FontSize',14);
%             title('Hamming filter', 'Interpreter','latex', 'FontSize',14);
%             
%             [hy,hx] = freqz(but_filt_b,but_filt_a);
%             hx = Fs*hx/(2*pi);
%             but_dB = mag2db(abs(hy));
%             subplot(2,1,2);
%             plot(hx, but_dB);
%             xlabel('f [$Hz$]', 'Interpreter','latex', 'FontSize',14);
%             ylabel('Magnitude ($dB$)', 'Interpreter','latex', 'FontSize',14);
%             title('Butterworth filter', 'Interpreter','latex', 'FontSize',14);
                

            figure;
            plot(Time,Fd, Time,Fd_filt);
            legend('F_d','F_{dfilt-ham}');
            
%             figure;
%             plot(Time,Fd, Time,Fd_filt, Time,Fd_filt2);
%             legend('F_d','F_{dfilt-ham}','F_{dfilt-butter}');
          
            [f, P1, y_temp] = getSingleSidedFourier(Fd, Fs);
            [f, P1_filt] = getSingleSidedFourier(Fd_filt, Fs);

            figure;
            hold on;
            plot(f,P1, f,P1_filt);
            plot([Fmax Fmax], [-0.1 max(P1)+0.1], 'r--','LineWidth',1.3);
            ylabel('Magnitude ($dB$)', 'Interpreter','latex', 'FontSize',14);
            xlabel('f [$Hz$]', 'Interpreter','latex', 'FontSize',14);
            hold off;
            legend('P_1','P_{1filt}');


            %[f, P1_filt] = getSingleSidedFourier(Fd_filt, Fs);
            T1 = 1/(2*Fmax);
            %N_sync = ceil(tau/T1);
            T_sync = 0:T1:tau;
            
            dmp.N_kernels = length(T_sync);
            %           dmp.c = T_sync';
            dmp.c = dmp.phase(T_sync)';
            %           dmp.h = T1;
            dmp.h = T1/tau;
            w_sync = interp1(Time, Fd_filt, T_sync);
            dmp.w = w_sync(:);
            

            F = zeros(size(Fd));
            for i=1:size(F,2)
                F(i) = dmp.learnedForcingTerm(x(i), y0, g);
            end

            train_error = norm(F-Fd)/length(F);
            y_temp(f>Fmax) = 0;
            Fd_temp = ifft(  y_temp);
            accuracy = sum((F-Fd_temp).^2) / sum(Fd_temp.^2);
            fprintf('Achieved accuracy: %.6f\n',accuracy);

%             c = dmp.c;
%             h = dmp.h;
%             w = dmp.w;
%             save('Shan_dat.mat','Time','x','s','Fd','F','P1','c','h','w');

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
        function [P] = update_weights(dmp, x, y, dy, ddy, y0, g, P, lambda)

            P = RLWR_update(dmp, x, y, dy, ddy, y0, g, P, lambda);

        end


        %% Calculates the desired values of the scaled forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] y: Position.
        %  @param[in] dy: Velocity.
        %  @param[in] ddy: Acceleration.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[in] g: current goal (if for instance the transition from y0 to g0 is done using a filter)        %  @param[out] Fd: Desired value of the scaled forcing term.
        function Fd = calcFd(dmp, x, y, dy, ddy, y0, g)

            v_scale = dmp.get_v_scale();
            s = (dmp.forcingTermScaling(y0, g) + dmp.zero_tol) * dmp.shapeAttrGating(x);
            Fd = (ddy*v_scale^2 - dmp.goalAttractor(x, y, v_scale*dy, g)) / s;

        end
        
        
        %% Returns the learned forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] learnForcTerm: The learned forcing term.
        function learnForcTerm = learnedForcingTerm(dmp, x, y0, g)

            learnForcTerm = dmp.forcingTerm(x);
            
        end


        %% Returns the forcing term of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[out] f: The normalized weighted sum of Gaussians.
        function f = forcingTerm(dmp,x)

            Psi = dmp.kernelFunction(x);
            f = dot(Psi,dmp.w);

        end


        %% Returns the scaling factor of the forcing term.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function f_scale = forcingTermScaling(dmp, y0, g)

            f_scale = (g-y0);

        end
        
        %% Returns the shape attractor gating factor.
        %  @param[in] x: The phase variable.
        function sAttrGat = shapeAttrGating(dmp, x)

            sAttrGat = DMP_shapeAttrGating(dmp,x);

        end
        
        
        %% Returns the goal attractor gating factor.
        %  @param[in] x: The phase variable.
        function gAttrGat = goalAttrGating(dmp, x)

            gAttrGat = DMP_goalAttrGating(dmp,x);

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
        %  @param[in] y0: Initial position.
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
        function [dy, dz] = getStatesDot(dmp, x, y, z, y0, g, y_c, z_c)

            if (nargin < 8), z_c=0; end
            if (nargin < 7), y_c=0; end

            [dy, dz] = DMP_getStatesDot(dmp, x, y, z, y0, g, y_c, z_c);

        end


        %% Returns a column vector with the values of the kernel functions of the DMP
        %  @param[in] x: phase variable
        %  @param[out] psi: column vector with the values of the kernel functions of the DMP
        function psi = kernelFunction(dmp,x)

            psi = sinc((x-dmp.c)./dmp.h);

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

        %% Parse extra arguments of the DMP
        %  @param[in] extraArgName: Names of extra arguments.
        %  @param[in] extraArgValue: Values of extra arguemnts.
        function parseExtraArgs(dmp, extraArgName, extraArgValue)

            dmp.Wmin = 0.95;
            dmp.Freq_min = 10;
            dmp.Freq_max = 200;
            dmp.P1_min = 0.5;

            for i=1:length(extraArgName)
                if (strcmp(extraArgName{i},'Wmin'))
                    dmp.Wmin = extraArgValue{i};
                elseif (strcmp(extraArgName{i},'Freq_min'))
                    dmp.Freq_min = extraArgValue{i};
                elseif (strcmp(extraArgName{i},'Freq_max'))
                    dmp.Freq_max = extraArgValue{i};
                elseif (strcmp(extraArgName{i},'P1_min'))
                    dmp.P1_min = extraArgValue{i};
                end
            end

            % to do: check if arguemnts are positive
        end


    end
end
