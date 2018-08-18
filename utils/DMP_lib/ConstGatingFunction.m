%% Constant Gating Function class
%  Implements a Constant gating function, u=f(x), x:[0 1]->u:[u_const u_const],
%  where u_const is the constant output value.
%  The output of the gating function is:
%     u = u_const;
%    du = 0.0;
%

classdef ConstGatingFunction < handle
   properties
       u0 % initial and constant value of the gating function
       a_u % the rate of evolution of the gating function (0.0 by default)
   end

   methods
      %% Constant Gating Function Constructor.
      %  @param[in] u0: Initial and constant value of the gating function (optional, default = 1.0).
      %  @param[in] u_end: Ignored for the constant gating function.
      %  @param[out] gating_fun: Gating function object.
      function gating_fun = ConstGatingFunction(u0, u_end)

          if (nargin < 1), u0 = 1.0; end
          if (nargin < 2), u_end = u0; end

          gating_fun.init(u0, u0);

      end

      %% Initializes the gating function.
      %  @param[in] u0: Initial and constant value of the gating function.
      %  @param[in] u_end: Ignored for the constant gating function.
      function init(gating_fun, u0, u_end)

          if (nargin < 3), u_end = u0; end

          gating_fun.setGatingFunParams(u0, u0);

      end

      %% Sets the gating function's time constants based on the value of
      %% the phase variable at the end of the movement.
      %  @param[in] u0: Initial and constant value of the gating function.
      %  @param[in] u_end: Final value of the gating function (ignored for constant gating function).
      function setGatingFunParams(gating_fun, u0, u_end)

          gating_fun.u0 = u0;
          gating_fun.a_u = 0.0;

      end

      %% Returns the gating function's output for the specified timestamps.
      %  @param[in] x: Vector of timestamps.
      %  @param[out] u: Vector of values of the gating function's output.
      function u = getOutput(gating_fun, x)

          u = gating_fun.u0 - gating_fun.a_u*x;

      end

      %% Returns the gating function's derivated output for the specified timestamps.
      %  @param[in] x: Vector of timestamps.
      %  @param[out] u: Vector of values of the gating function's derivated output.
      function du = getOutputDot(gating_fun, x)

          du = -gating_fun.a_u * ones(size(x));

      end


   end
end
