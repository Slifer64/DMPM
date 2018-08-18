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
function [P] = RLWR_update(dmp, x, y, dy, ddy, y0, g, P, lambda)

    Fd = dmp.calcFd(y, dy, ddy, x, y0, g);
    s = dmp.forcingTermScaling(x, y0, g);
    psi = dmp.kernelFunction(x);
    
    error = Fd - dmp.w*s;
    
    P = (P - (P.^2.*s.^2) ./ (lambda./psi + P.*s.^2)) / lambda;
    dmp.w = dmp.w + psi.*P.*s.*error; 
    
end


