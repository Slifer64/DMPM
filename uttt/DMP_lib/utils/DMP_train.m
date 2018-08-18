%% Trains the DMP
%  @param[in] dmp: The DMP object.
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
function [train_error, F, Fd] = DMP_train(dmp, Time, yd_data, dyd_data, ddyd_data, y0, g)

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

    trainMethod = dmp.trainMethod;
    if (strcmpi(trainMethod,'LWR'))

        dmp.w = LWR(Psi, s, Fd, dmp.zero_tol);

    elseif (strcmpi(trainMethod,'RLWR'))

        dmp.w = RLWR(Psi, s, Fd, dmp.lambda, dmp.P_rlwr);

    elseif (strcmpi(trainMethod,'LS'))

        dmp.w = normKernelLS(Psi, s, Fd, dmp.zero_tol);

    else
        error('Unsopported training method ''%s''', trainMethod);
    end

    F = zeros(size(Fd));
    for i=1:size(F,2)
        F(i) = dmp.learnedForcingTerm(x(i), y0, g);
    end


    train_error = norm(F-Fd)/length(F);

end
