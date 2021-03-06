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

classdef DMP < handle % : public DMP_
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

    end

    methods
        %% DMP constructor
        %  @param[in] N_kernels: the number of kernels
        %  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
        %  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
        %  @param[in] canClockPtr: Pointer to a DMP canonical system object.
        function dmp = DMP(N_kernels, a_z, b_z, canClockPtr)

            dmp.shapeAttrGatingPtr = SigmoidGatingFunction(1.0, 0.99);
            dmp.goalAttrGatingPtr = ConstGatingFunction(1.0);

            dmp.init(N_kernels, a_z, b_z, canClockPtr);

        end


        %% Initializes the DMP
        %  @param[in] N_kernels: the number of kernels
        %  @param[in] a_z: Parameter 'a_z' relating to the spring-damper system.
        %  @param[in] b_z: Parameter 'b_z' relating to the spring-damper system.
        %  @param[in] canClockPtr: Pointer to a DMP canonical system object.
        function init(dmp, N_kernels, a_z, b_z, canClockPtr)

            dmp.zero_tol = 1e-30;%realmin;

            kernelStdScaling = 1.0;

            dmp.N_kernels = N_kernels;
            dmp.a_z = a_z;
            dmp.b_z = b_z;
            dmp.canClockPtr = canClockPtr;

            dmp.w = zeros(dmp.N_kernels,1); %rand(dmp.N_kernels,1);
            dmp.setCenters();
            dmp.setStds(kernelStdScaling);

        end


        %% Sets the centers for the kernel functions of the DMP according to the canonical system
        function setCenters(dmp)

            t = ((1:dmp.N_kernels)-1)/(dmp.N_kernels-1);
            x = dmp.phase(t*dmp.getTau());
            dmp.c = x(1,:)';

        end


        %% Sets the standard deviations for the kernel functions  of the DMP
        %  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
        %  @param[in] kernelStdScaling: Scales the std of each kernel by 'kernelStdScaling' (optional, default = 1.0).
        function setStds(dmp, kernelStdScaling)
            
            if (nargin < 2), kernelStdScaling=1.0; end

            dmp.h = 1./(kernelStdScaling*(dmp.c(2:end)-dmp.c(1:end-1))).^2;
            dmp.h = [dmp.h; dmp.h(end)];

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
        function [train_error, F, Fd] = train(dmp, train_method, Time, yd_data, dyd_data, ddyd_data)

            n_data = length(Time);
            
            tau0 = dmp.canClockPtr.getTau();
            
            tau = Time(end);
            y0 = yd_data(:,1);
            g = yd_data(:,end);
            
            dmp.canClockPtr.setTau(tau);
    
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

            if (strcmpi(train_method,'LWR'))

                dmp.w = LWR(Psi, s, Fd, dmp.zero_tol);

            elseif (strcmpi(train_method,'LS'))

                dmp.w = normKernelLS(Psi, s, Fd, dmp.zero_tol);

            else
                error('Unsopported training method ''%s''', train_method);
            end

            F = zeros(size(Fd));
            for i=1:size(F,2)
                F(i) = dmp.learnedForcingTerm(x(i), y0, g);
            end

            train_error = norm(F-Fd)/length(F);
            
%             dmp.canClockPtr.setTau(tau0);

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

            tau = dmp.getTau();
            Fd = (ddy*tau^2 - dmp.goalAttractor(x, y, tau*dy, g));

        end
        
        
        %% Returns the learned forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function learnForcTerm = learnedForcingTerm(dmp, x, y0, g)

            learnForcTerm = dmp.shapeAttrGating(x) * dmp.forcingTerm(x) * dmp.forcingTermScaling(y0, g);
            
        end


        %% Returns the forcing term of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[out] f: The normalized weighted sum of Gaussians.
        function f = forcingTerm(dmp,x)

            Psi = dmp.kernelFunction(x);
    
            f = dot(Psi,dmp.w) / (sum(Psi)+dmp.zero_tol); % add 'zero_tol' to avoid numerical issues

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

            sAttrGat = dmp.shapeAttrGatingPtr.getOutput(x);
            sAttrGat(sAttrGat<0) = 0.0;

        end
        
        
        %% Returns the goal attractor gating factor.
        %  @param[in] x: The phase variable.
        function gAttrGat = goalAttrGating(dmp, x)

            gAttrGat = dmp.goalAttrGatingPtr.getOutput(x);
            gAttrGat(gAttrGat>1.0) = 1.0;

        end


        %% Returns the goal attractor of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[in] y: \a y state of the DMP.
        %  @param[in] z: \a z state of the DMP.
        %  @param[in] g: Goal position.
        %  @param[out] goal_attr: The goal attractor of the DMP.
        function goal_attr = goalAttractor(dmp, x, y, z, g)

            g_attr_gating = dmp.goalAttrGating(x);
            goal_attr = g_attr_gating * dmp.a_z*(dmp.b_z*(g-y)-z);

        end


        %% Returns the shape attractor of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[in] y0: initial position.
        %  @param[in] g: Goal position.
        %  @param[out] shape_attr: The shape_attr of the DMP.
        function shape_attr = shapeAttractor(dmp, x, y0, g)
            
            s_attr_gating = dmp.shapeAttrGating(x);
            f = dmp.forcingTerm(x);
            f_scale = dmp.forcingTermScaling(y0, g);
            shape_attr = s_attr_gating * f * f_scale;
            
        end
        
        
        %% Returns the phase variable.
        %  @param[in] t: The time instant.
        %  @param[out] x: The phase variable for time 't'.
        function x = phase(dmp, t)
            
            x = dmp.canClockPtr.getPhase(t);

        end
        
        
        %% Returns the derivative of the phase variable.
        %  @param[in] x: The phase variable.
        %  @param[out] dx: The derivative of the phase variable.
        function dx = phaseDot(dmp, x)
            
            dx = dmp.canClockPtr.getPhaseDot(x);

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

            if (nargin < 8), y_c=0; end
            if (nargin < 7), z_c=0; end

            tau = dmp.getTau();

            shape_attr = dmp.shapeAttractor(x, y0, g);
            goal_attr = dmp.goalAttractor(x, y, z, g);

            dz = ( goal_attr + shape_attr + z_c) / tau;

            dy = ( z + y_c) / tau;

            dx = dmp.phaseDot(x);

        end


        %% Returns a column vector with the values of the kernel functions of the DMP
        %  @param[in] x: phase variable
        %  @param[out] psi: column vector with the values of the kernel functions of the DMP
        function psi = kernelFunction(dmp,x)

            n = length(x);
            psi = zeros(dmp.N_kernels, n);

            for j=1:n
                psi(:,j) = exp(-dmp.h.*((x(j)-dmp.c).^2));
            end 

        end

        
        %% Returns the time cycle of the DMP
        %  @param[out] tau: The time duration of the DMP.
        function tau = getTau(dmp)

            tau = dmp.canClockPtr.getTau();

        end

    end
end
