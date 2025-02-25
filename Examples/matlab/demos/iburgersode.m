function iburgersode(N)
%IBURGERSODE  Burgers' equation solved as implicit ODE system
%   IBURGERSODE(N) solves Burgers' equation,  Du/Dt = 1e-4 * D^2 u/Dx^2 -
%   D(0.5u^2)/Dx, on 0 <= x <= 1 with u(x,0) = sin(2*pi*x) + 0.5*sin(pi*x)
%   and u(0,t) = 0,u(1,t) = 0 on a (moving) mesh of N points. This is Problem 2
%   of W. Huang, Y. Ren, and R.D. Russell, Moving mesh methods based on moving
%   mesh partial differential equations, J. Comput. Phys. 113(1994) 279-290.
%   In that paper, Burger's equation is discretized with central differences
%   as sketched in (19) and the moving mesh PDE used is MMPDE6 with tau = 1e-3.
%   Figure 6 shows the solution when N = 20 and spatial smoothing is done
%   with gamma = 2 and p = 2.  The problem was solved with a relative error
%   tolerance of 1e-5 and an absolute error tolerance of 1e-4.
%
%   In this example, the plot of the solution is much like Figure 6 of the paper,
%   but the initial data is plotted and to reduce the run time, the problem is
%   integrated only to t = 1.  The discretized problem is solved as a fully
%   implicit system f(t,y,y') = 0. The solution vector y = (a1,...,aN,x1,...,xN).
%   At time t, aj approximates the solution u(t,xj) of the PDE. The mesh point xj
%   is a function of time (moving mesh).  Providing the exact derivative df/dy'
%   and specifying the sparsity pattern for df/dy significantly reduces the run
%   time.
%
%   See also ODE15I, BURGERSODE, ODESET, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2014 The MathWorks, Inc.

% Problem parameter, shared with nested functions
if nargin < 1
   N = 19;
end

% Use initial grid xinit of N equally spaced points.
h = 1/(N+1);
xinit = h*(1:N)';
% u(x,0) at grid points
ainit = sin(2*pi*xinit) + 0.5*sin(pi*xinit);

y0 = [ainit; xinit];
yp0 = zeros(size(y0));
tspan = [0 1];

% Sparsity pattern of df/dy
JP = JPat(N) | MvPat(N);

opts = odeset('RelTol',1e-5,'AbsTol',1e-4,'Jacobian',@Jac,'Jpattern',{JP,[]});

% Compute consistent initial conditions.
[y0,yp0] = decic(@Fimpl,tspan(1),y0,[],yp0,[],opts);

% Solve the problem.
sol = ode15i(@Fimpl,tspan,y0,yp0,opts);

% Evaluate and plot the solution at specified points.
tint = [0, 0.2, 0.6, 1.0];
yint = deval(sol,tint);
% The mesh points at the ends of the interval are fixed, so x(0) = 0 and
% x(N+1) = 1.  The boundary values u(t,0) = 0 = a(0) and u(t,1) = 0 = a(N+1).
% Add these known values to the computed ones for the figures.
figure;
color = 'bgrc';
labels = {};
for j = 1:length(tint)
   solution  = [0; yint(1:N,j); 0];
   location  = [0; yint(N+1:end,j); 1];
   style = [color(j) '-o'];
   labels{j} = ['t = ' num2str(tint(j))];
   plot(location,solution,style)
   hold on
end
xlabel('x');
ylabel('solution u');
legend(labels{:})
title('Burgers equation. Implicit ODE. MMPDE6')
hold off
drawnow

% Plot the grid movement.
figure
plot(sol.y(N+1:end,:),sol.x)
xlabel('x')
ylabel('t')
title('Burgers equation. Grid trajectories')

% -----------------------------------------------------------------------
% Nested functions -- N is provided by the outer function.
%

   function out = f(t,y)
      % The derivative function from the linearly implicit formulation
      % solved in BURGERSODE.
      a = y(1:N);  % N is shared with the outer function.
      x = y(N+1:end);
      x0 = 0;
      a0 = 0;
      xNP1 = 1;
      aNP1 = 0;
      g = zeros(2*N,1);
      for i = 2:N-1
         delx = x(i+1) - x(i-1);
         g(i) = 1e-4*((a(i+1) - a(i))/(x(i+1) - x(i)) - ...
            (a(i) - a(i-1))/(x(i) - x(i-1)))/(0.5*delx) ...
            - 0.5*(a(i+1)^2 - a(i-1)^2)/delx;
      end
      delx = x(2) - x0;
      g(1) = 1e-4*((a(2) - a(1))/(x(2) - x(1)) - (a(1) - a0)/(x(1) - x0))/(0.5*delx) ...
         - 0.5*(a(2)^2 - a0^2)/delx;
      delx = xNP1 - x(N-1);
      g(N) = 1e-4*((aNP1 - a(N))/(xNP1 - x(N)) - ...
         (a(N) - a(N-1))/(x(N) - x(N-1)))/delx - 0.5*(aNP1^2 - a(N-1)^2)/delx;
      % Evaluate monitor function.
      M = zeros(N,1);
      for i = 2:N-1
         M(i) = sqrt(1 + ((a(i+1) - a(i-1))/(x(i+1) - x(i-1)))^2);
      end
      M0 = sqrt(1 + ((a(1) - a0)/(x(1) - x0))^2);
      M(1) = sqrt(1 + ((a(2) - a0)/(x(2) - x0))^2);
      M(N) = sqrt(1 + ((aNP1 - a(N-1))/(xNP1 - x(N-1)))^2);
      MNP1 = sqrt(1 + ((aNP1 - a(N))/(xNP1 - x(N)))^2);
      % Spatial smoothing with gamma = 2, p = 2.
      SM = zeros(N,1);
      for i = 3:N-2
         SM(i) = sqrt((4*M(i-2)^2 + 6*M(i-1)^2 + 9*M(i)^2 + ...
            6*M(i+1)^2 + 4*M(i+2)^2)/29);
      end
      SM0 = sqrt((9*M0^2 + 6*M(1)^2 + 4*M(2)^2)/19);
      SM(1) = sqrt((6*M0^2 + 9*M(1)^2 + 6*M(2)^2 + 4*M(3)^2)/25);
      SM(2) = sqrt((4*M0^2 + 6*M(1)^2 + 9*M(2)^2 + 6*M(3)^2 + 4*M(4)^2)/29);
      SM(N-1) = sqrt((4*M(N-3)^2 + 6*M(N-2)^2 + 9*M(N-1)^2 + 6*M(N)^2 + 4*MNP1^2)/29);
      SM(N) = sqrt((4*M(N-2)^2 + 6*M(N-1)^2 + 9*M(N)^2 + 6*MNP1^2)/25);
      SMNP1 = sqrt((4*M(N-1)^2 + 6*M(N)^2 + 9*MNP1^2)/19);
      for i = 2:N-1
         g(i+N) = (SM(i+1) + SM(i))*(x(i+1) - x(i)) - ...
            (SM(i) + SM(i-1))*(x(i) - x(i-1));
      end
      g(1+N) = (SM(2) + SM(1))*(x(2) - x(1)) - (SM(1) + SM0)*(x(1) - x0);
      g(N+N) = (SMNP1 + SM(N))*(xNP1 - x(N)) - (SM(N) + SM(N-1))*(x(N) - x(N-1));
      tau = 1e-3;
      g(1+N:end) = - g(1+N:end)/(2*tau);
      out = g;
   end
% -----------------------------------------------------------------------

   function out = mass(t,y)
      % Mass matrix from the linearly implicit formulation solved in BURGERSODE
      a = y(1:N);  % N is shared with the outer function.
      x = y(N+1:end);
      x0 = 0;
      a0 = 0;
      xNP1 = 1;
      aNP1 = 0;
      M1 = speye(N);
      M2 = sparse(N,N);
      M2(1,1) = - (a(2) - a0)/(x(2) - x0);
      for i = 2:N-1
         M2(i,i) = - (a(i+1) - a(i-1))/(x(i+1) - x(i-1));
      end
      M2(N,N) = - (aNP1 - a(N-1))/(xNP1 - x(N-1));
      % MMPDE6
      M3 = sparse(N,N);
      e = ones(N,1);
      M4 = spdiags([e -2*e e],-1:1,N,N);
      out = [M1 M2
         M3 M4];
   end
% -----------------------------------------------------------------------

   function res = Fimpl(t,y,yp)
      % Burgers' equation -- fully implicit formulation
      res = mass(t,y)*yp - f(t,y);
   end
% -----------------------------------------------------------------------

   function [dfdy,dfdyp] = Jac(t,y,yp)
      % Jacobian function for fully implicit Burger's equation
      dfdy = [];  % ODE15i will use numerical approximation.
      dfdyp = mass(t,y);
   end
% -----------------------------------------------------------------------

end  % iburgersode

% -------------------------------------------------------------------------
% Auxiliary functions -- sparsity patterns for
% the linearly implicit formulation (BURGERSODE)

function out = JPat(N)
% Jacobian sparsity pattern for the derivative function
S1 = spdiags(ones(N,3),-1:1,N,N);
S2 = spdiags(ones(N,9),-4:4,N,N);
out = [S1 S1
   S2 S2];
end
% -------------------------------------------------------------------------

function S = MvPat(N)
% Sparsity pattern for the derivative of the mass matrix times a vector
S = sparse(2*N,2*N);
S(1,2) = 1;
S(1,2+N) = 1;
for i = 2:N-1
   S(i,i-1) = 1;
   S(i,i+1) = 1;
   S(i,i-1+N) = 1;
   S(i,i+1+N) = 1;
end
S(N,N-1) = 1;
S(N,N-1+N) = 1;
end
% -------------------------------------------------------------------------
