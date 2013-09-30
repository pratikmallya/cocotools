function [opts argnum] = curve_PD2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at a period-doubling
% point found in a previous run. Called by coco as follows:
%   coco(opts, RUN, 'curve','PD','sol', RRUN, RLAB, PAR, PAR_INT)

% In principle, this function could handle more arguments for
% user-friendliness, or perform some error-tests.

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
fx = data.fx;
fp = data.fp;
T  = data.T;
Tp = data.Tp;
q  = data.q;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% compute tangent vector at period-doubled branch and predict new initial
% point
J       = map_q_DFDX(data,q,T(p0),x0,p0);
[X D]   = eig(J);
[t idx] = min( abs(diag(D)+1) ); %#ok<ASGLU>
t       = X(:,idx);
t       = t/norm(t);

% use COCO to compute initial value
data.q = 2*q;
[x0 p0] = computeFirstPoint(opts, data, x0, p0, t);

% We pass the computed initial guess to the constructor.
opts = curve_create(opts, f,fx,fp,T,Tp, x0, p0, data.q);

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end

function J = map_q_DFDX(data,q,T,x,p)
  function y = VarEQN(data, t,p,m, xx)
    x  = xx(1:m);
    M  = reshape(xx(m+1:m*m+m), m,m);
    Jx = data.fx(t,x,p);
    y  = [ data.f(t,x,p) Jx*M ];
    y  = y(:);
  end
m     = numel(x);
f     = @(t,M) VarEQN(data, t,p,m, M);
M0    = [x eye(m,m)];
[t M] = data.ODEsolver(f, [0 0.5*T q*T], M0(:), data.ode_opts); %#ok<ASGLU>
M     = M(end,:);
J     = reshape(M(m+1:end), m,m);
end

