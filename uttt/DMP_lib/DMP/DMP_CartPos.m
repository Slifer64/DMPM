%% DMP Cartesian Position class
%  Implements an 3-D DMP representing the Cartesian position.
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

classdef DMP_CartPos < handle
    properties
        dmp % vector 3x1 of 1-D DMPs
        D % dimensionality of the DMP_CartPos (= 3, constant)
    end

    methods
        %% DMP constructor
        %  @param[in] vec3D_dmp: 3x1 cell array of 1D DMPs.
        function dmp_CartPos = DMP_CartPose(vec3D_dmp)

            if (nargin < 1)
                return;
            else
                dmp_CartPos.init(vec3D_dmp);
            end

        end


        %% Initializes the DMP
        %  @param[in] vec3D_dmp: 3x1 cell array of 1D DMPs.
        function init(dmp_CartPos, vec3D_dmp)
            
            dmp_CartPos.D = 3;
            dmp_CartPos.dmp = cell(3,1);
            
            for i=1:dmp_CartPos.D
                dmp_CartPos.dmp{i} = vec3D_dmp{i};
            end

        end


        %% Sets the centers for the kernel functions of the DMP according to the canonical system
        function setCenters(dmp_CartPos)

            for i=1:dmp_CartPos.D
                dmp_CartPos.dmp{i}.setCenters();
            end

        end


        %% Sets the standard deviations for the kernel functions  of the DMP
        %  Sets the variance of each kernel equal to squared difference between the current and the next kernel.
        %  @param[in] kernelStdScaling: Scales the variance of each kernel by 'kernelStdScaling' (optional, default = 1.0).
        function setStds(dmp_CartPos, kernelStdScaling)

            if (nargin < 2), kernelStdScaling=1.0; end
            for i=1:dmp_CartPos.D
                dmp_CartPos.dmp{i}.setStds(kernelStdScaling);
            end

        end


        %% Trains the DMP
        %  @param[in] Time: Row vector with the timestamps of the training data points.
        %  @param[in] Y_data: Matrix with the Cartesian position in each column.
        %  @param[in] dY_data: Matrix with the Cartesian velocity in each column.
        %  @param[in] ddY_data: Matrix with the Cartesian acceleration in each column.
        %  @param[in] Y0: Initial Cartesian position.
        %  @param[in] Yg: Target-goal Cartesian position.
        %
        %  \note The timestamps in \a Time and the corresponding position,
        %  velocity and acceleration data in \a Y_data, \a dY_data and \a
        %  ddY_data need not be sequantial in time.
        function [train_error, F, Fd] = train(dmp_CartPos, Time, Y_data, dY_data, ddY_data, Y0, Yg)

            train_error = zeros(dmp_CartPos.D,1);
            F = zeros(dmp_CartPos.D, length(Time));
            Fd = zeros(dmp_CartPos.D, length(Time));

            for i=1:dmp_CartPos.D
                [train_error(i), F(i,:), Fd(i,:)] = dmp_CartPos.dmp{i}.train(Time, Y_data(i,:), dY_data(i,:), ddY_data(i,:), Y0(i), Yg(i));
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
        function setTrainingParams(dmp_CartPos, trainMethod, extraArgName, extraArgValue)

            for i=1:dmp_CartPos.D
                dmp_CartPos.dmp{i}.setTrainingParams(trainMethod, extraArgName, extraArgValue);
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
        function [P] = update_weights(dmp_CartPos, x, y, dy, ddy, y0, g, P, lambda)

            P = RLWR_update(dmp_CartPos, x, y, dy, ddy, y0, g, P, lambda);

        end

        %% Calculates the desired values of the scaled forcing term.
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[in] Y: Cartesian position.
        %  @param[in] dY: Cartesian velocity.
        %  @param[in] ddY: Cartesian acceleration.
        %  @param[in] Y0: Initial Cartesian position.
        %  @param[in] Yg: Goal Cartesian position.
        %  @param[out] Fd: Desired value of the scaled forcing term.
        function Fd = calcFd(dmp_CartPos, X, Y, dY, ddY, Y0, Yg)

            Fd = zeros(dmp_CartPos.D, 1);
            for i=1:dmp_CartPos.D
                Fd(i) = dmp_CartPos.dmp{i}.calcFd(X(i), Y(i), dY(i), ddY(i), Y0(i), Yg(i));
            end

        end


        %% Returns the forcing term of the DMP.
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[out] f: The normalized weighted sum of Gaussians.
        function f = forcingTerm(dmp_CartPos, X)

            f = zeros(dmp_CartPos.D,1);
            for i=1:dmp_CartPos.D
                f(i) = dmp_CartPos.dmp{i}.forcingTerm(X(i));
            end

        end

        %% Returns the scaling factor of the forcing term.
        %  @param[in] Y0: Initial Cartesian position.
        %  @param[in] Yg: Goal Cartesian position.
        %  @param[out] f_scale: The scaling factor of the forcing term.
        function f_scale = forcingTermScaling(dmp_CartPos, Y0, Yg)

            f_scale = zeros(dmp_CartPos.D,1);
            for i=1:dmp_CartPos.D
                f_scale(i) = dmp_CartPos.dmp{i}.forcingTermScaling(Y0(i), Yg(i));
            end

        end

        %% Returns the goal attractor of the DMP.
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[in] Y: \a y state of the DMP.
        %  @param[in] Z: \a z state of the DMP.
        %  @param[in] Yg: Goal Cartesian position.
        %  @param[out] goal_attr: The goal attractor of the DMP.
        function goal_attr = goalAttractor(dmp_CartPos, X, Y, Z, Yg)

            goal_attr = zeros(dmp_CartPos.D, 1);
            for i=1:dmp_CartPos.D
                goal_attr(i) = dmp_CartPos.dmp{i}.goalAttractor(X(i), Y(i), Z(i), Yg(i));
            end

        end


        %% Returns the shape attractor of the DMP.
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[in] Y0: Initial Cartesian position.
        %  @param[in] Yg: Goal Cartesian position.
        %  @param[out] shape_attr: The shape_attr of the DMP.
        function shape_attr = shapeAttractor(dmp_CartPos, X, Y0, Yg)

            shape_attr = zeros(dmp_CartPos.D,1);
            for i=1:dmp_CartPos.D
                shape_attr(i) = dmp_CartPos.dmp{i}.shapeAttractor(X(i), Y0(i), Yg(i));
            end

        end


        %% Returns the derivatives of the DMP states
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[in] Y: \a y state of the DMP.
        %  @param[in] Z: \a z state of the DMP.
        %  @param[in] Y0: Initial position.
        %  @param[in] Yg: Goal position.
        %  @param[in] Y_c: Coupling term for the dynamical equation of the \a y state.
        %  @param[in] Z_c: Coupling term for the dynamical equation of the \a z state.
        %  @param[out] dY: Derivative of the \a y state of the DMP.
        %  @param[out] dZ: Derivative of the \a z state of the DMP.
        function [dY, dZ] = getStatesDot(dmp_CartPos, X, Y, Z, Y0, Yg, Y_c, Z_c)

            if (nargin < 8), Z_c=zeros(dmp_CartPos.D, 1); end
            if (nargin < 7), Y_c=zeros(dmp_CartPos.D, 1); end
            
            dY = zeros(dmp_CartPos.D, 1);
            dZ = zeros(dmp_CartPos.D, 1);
            

            for i=1:dmp_CartPos.D
                [dY(i), dZ(i)] = dmp_CartPos.dmp{i}.getStatesDot(X(i), Y(i), Z(i), Y0(i), Yg(i), Y_c(i), Z_c(i));
            end

        end


        %% Returns a column vector with the values of the kernel functions of the DMP
        %  @param[in] X: 3x1 vector with the phase variable of each DMP.
        %  @param[out] Psi: 3x1 cell array of column vectors with the values of the kernel functions of each DMP.
        function Psi = kernelFunction(dmp_CartPos, X)

            Psi = cell(dmp_CartPos.D,1);
            for i=1:dmp_CartPos.D
                Psi{i} = dmp_CartPos.dmp{i}.kernelFunction(X(i));
            end

        end


        %% Returns the scaling factor of the DMP
        %  @param[out] v_scale: 3x1 vector with the scaling factor of each DMP.
        function v_scale = get_v_scale(dmp_CartPos)

            v_scale = zeros(dmp_CartPos.D,1);
            for i=1:dmp_CartPos.D
                v_scale(i) = dmp_CartPos.dmp{i}.get_v_scale();
            end 

        end


        %% Returns the time cycle of the DMP
        %  @param[out] tau: 3x1 vector with the time duration of each DMP.
        function tau = getTau(dmp_CartPos)

            tau = zeros(dmp_CartPos.D,1);
            for i=1:3
                tau(i) = dmp_CartPos.dmp{i}.getTau();
            end

        end


    end
end
