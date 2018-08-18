%% DMP orientation class
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

classdef DMP_orient < handle
    properties
        dmp % vector 3x1 of DMPs
        D % dimensionality of the orientation DMP (= 3, constant)
    end

    methods
        %% DMP constructor
        %  @param[in] vec3D_dmp: 3x1 cell array of 1D DMPs.
        function dmp_o = DMP_orient(vec3D_dmp)

            if (nargin < 1)
                return;
            else
                dmp_o.init(vec3D_dmp);
            end

        end


        %% Initializes the DMP
         %  @param[in] vec3D_dmp: 3x1 cell array of 1D DMPs.
        function init(dmp_o, vec3D_dmp)

            dmp_o.D = 3;
            dmp_o.dmp = cell(3,1);
            
            for i=1:dmp_o.D
                dmp_o.dmp{i} = vec3D_dmp{i};
            end

        end


        %% Sets the centers for the kernel functions of the DMP according to the canonical system
        function setCenters(dmp_o)

            for i=1:3
                dmp_o.dmp{i}.setCenters();
            end

        end


        %% Sets the standard deviations for the kernel functions  of the DMP
        %  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
        %  @param[in] kernelStdScaling: Scales the variance of each kernel by 'kernelStdScaling' (optional, default = 1.0).
        function setStds(dmp_o, kernelStdScaling)

            if (nargin < 2), kernelStdScaling=1.0; end
            for i=1:dmp_o.D
                dmp_o.dmp{i}.setStds(kernelStdScaling);
            end

        end


        %% Trains the DMP
        %  @param[in] Time: Row vector with the timestamps of the training data points.
        %  @param[in] Q_data: Matrix where each column expresses the orientation as a unit quaternion.
        %  @param[in] v_rot_data: Matrix where each column expresses the desired angular velocity.
        %  @param[in] dv_rot_data: Matrix where each column expresses the desired angular acceleration.
        %  @param[in] Q0: Initial orientation as 4x1 unit quaternion.
        %  @param[in] Qg: Target-goal orientation as 4x1 unit quaternion.
        %
        %  \note The timestamps in \a Time and the corresponding position,
        %  velocity and acceleration data in \a Q_data, \a v_rot_data and \a
        %  dv_rot_data need not be sequantial in time.
        function [train_error, F, Fd] = train(dmp_o, Time, Q_data, v_rot_data, dv_rot_data, Q0, Qg)

            train_error = zeros(3,1);
            F = zeros(3, length(Time));
            Fd = zeros(3, length(Time));

            yd_data = zeros(3, size(Q_data,2));
            for i=1:size(yd_data,2)
               yd_data(:,i) = -quatLog(quatProd(Qg,quatInv(Q_data(:,i))));
            end

            y0 = -quatLog(quatProd(Qg,quatInv(Q0)));

            for i=1:3
                [train_error(i), F(i,:), Fd(i,:)] = dmp_o.dmp{i}.train(Time, yd_data(i,:), v_rot_data(i,:), dv_rot_data(i,:), y0(i), 0);
            end

        end


        %% Sets the high level training parameters of the DMP
        %  @param[in] trainMethod: Method used to train the DMP weights.
        %  @param[in] extraArgName: Names of extra arguments (optional, default = []).
        %  @param[in] extraArgValue: Values of extra arguemnts (optional, default = []).
        %
        %  \remark The extra argument names can be the following:
        %  'lambda': Forgetting factor for recursive training methods.
        %  'P_cov': Initial value of the covariance matrix for recursive training methods.
        function setTrainingParams(dmp_o, trainMethod, extraArgName, extraArgValue)

            for i=1:3
                dmp_o.dmp{i}.setTrainingParams(trainMethod, extraArgName, extraArgValue);
            end

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
        function [P] = update_weights(dmp_o, x, y, dy, ddy, y0, g, P, lambda)

            P = RLWR_update(dmp_o, x, y, dy, ddy, y0, g, P, lambda);

        end

        %% Calculates the desired values of the scaled forcing term.
        %  @param[in] x: The phase variable.
        %  @param[in] Q: Orientation as 4x1 unit quaternion.
        %  @param[in] v_rot: Angular velocity.
        %  @param[in] dv_rot: Angular acceleration.
        %  @param[in] Q0: Initial orientation as 4x1 unit quaternion.
        %  @param[in] Qg: Goal orientation as 4x1 unit quaternion.
        %  @param[out] Fd: Desired value of the scaled forcing term.
        function Fd = calcFd(dmp_o, X, Q, v_rot, dv_rot, Q0, Qg)

            y = -quatLog(quatProd(Qg,quatInv(Q)));
            y0 = -quatLog(quatProd(Qg,quatInv(Q0)));
            g = zeros(3,1);
            dy = v_rot;
            ddy = dv_rot;

            Fd = zeros(3, 1);
            for i=1:3
                Fd(i) = dmp_o.dmp{i}.calcFd(X(i), y(i), dy(i), ddy(i), y0(i), g(i));
            end

        end


        %% Returns the forcing term of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[out] f: The normalized weighted sum of Gaussians.
        function f = forcingTerm(dmp_o, X)

            f = zeros(3,1);
            for i=1:3
                f(i) = dmp_o.dmp{i}.forcingTerm(X(i));
            end

        end

        %% Returns the scaling factor of the forcing term.
        %  @param[in] Q0: Initial orientation as 4x1 unit quaternion.
        %  @param[in] Qg: Goal orientation as 4x1 unit quaternion.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function f_scale = forcingTermScaling(dmp_o, Q0, Qg)

            y0 = -quatLog(quatProd(Qg,quatInv(Q0)));
            g = zeros(3,1);

            f_scale = zeros(3,1);
            for i=1:3
                f_scale(i) = dmp_o.dmp{i}.forcingTermScaling(y0(i), g(i));
            end

        end

        %% Returns the goal attractor of the DMP.
        %  @param[in] x: The phase variable.
        %  @param[in] Q: \a Q state of the DMP.
        %  @param[in] eta: \a eta state of the DMP.
        %  @param[in] Qg: Goal orientation as 4x1 unit quaternion.
        %  @param[out] goal_attr: The goal attractor of the DMP.
        function goal_attr = goalAttractor(dmp_o, X, Q, eta, Qg)

            goal_attr = zeros(3, 1);
            y = -quatLog(quatProd(Qg, quatInv(Q)));
            for i=1:3
                goal_attr(i) = dmp_o.dmp{i}.goalAttractor(X(i), y(i), eta(i), 0);
            end

        end


        %% Returns the shape attractor of the DMP.
        %  @param[in] X: The phase variable.
        %  @param[in] Q0: Initial orientation as 4x1 unit quaternion.
        %  @param[in] Qg: Goal orientation as 4x1 unit quaternion.
        %  @param[out] shape_attr: The shape_attr of the DMP.
        function shape_attr = shapeAttractor(dmp_o, X, Q0, Qg)

            y0 = -quatLog(quatProd(Qg,quatInv(Q0)));
            g = zeros(3,1);

            shape_attr = zeros(3,1);
            for i=1:3
                shape_attr(i) = dmp_o.dmp{i}.shapeAttractor(X(i), y0(i), g(i));
            end

        end


        %% Returns the derivatives of the DMP states
        %  @param[in] X: The phase variable.
        %  @param[in] Q: \a Q state of the DMP.
        %  @param[in] eta: \a eta state of the DMP.
        %  @param[in] Q0: Initial orientation as 4x1 unit quaternion.
        %  @param[in] Qg: Goal orientation as 4x1 unit quaternion.
        %  @param[in] Q_c: Coupling term for the dynamical equation of the \a Q state.
        %  @param[in] eta_c: Coupling term for the dynamical equation of the \a eta state.
        %  @param[out] dQ: Derivative of the \a Q state of the DMP.
        %  @param[out] deta: Derivative of the \a eta state of the DMP.
        function [dQ, deta] = getStatesDot(dmp_o, X, Q, eta, Q0, Qg, Q_c, eta_c)

            if (nargin < 8), eta_c=0; end
            if (nargin < 7), Q_c=0; end

            v_scale = dmp_o.get_v_scale();
            shape_attr = dmp_o.shapeAttractor(X, Q0, Qg);
            goal_attr = dmp_o.goalAttractor(X, Q, eta, Qg);

            deta = ( goal_attr + 0*shape_attr + eta_c) ./ v_scale;
            dQ = 0.5*quatProd([0; (eta+Q_c)./ v_scale], Q);

        end


        %% Returns a column vector with the values of the kernel functions of the DMP
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[out] Psi: 3x1 cell array of column vectors with the values of the kernel functions of each DMP.
        function Psi = kernelFunction(dmp_o, X)

            Psi = cell(dmp_o.D,1);
            for i=1:dmp_o.D
                Psi{i} = dmp_o.dmp{i}.kernelFunction(X(i));
            end

        end


        %% Returns the scaling factor of the DMP
        %  @param[out] v_scale: 3x1 vector with the scaling factor of each DMP.
        function v_scale = get_v_scale(dmp_o)

            v_scale = zeros(dmp_o.D,1);
            for i=1:dmp_o.D
                v_scale(i) = dmp_o.dmp{i}.get_v_scale();
            end 

        end


        %% Returns the time cycle of the DMP
        %  @param[out] tau: 3x1 vector with the time duration of each DMP.
        function tau = getTau(dmp_o)

            tau = zeros(dmp_o.D,1);
            for i=1:3
                tau(i) = dmp_o.dmp{i}.getTau();
            end

        end


    end
end
