function [opts argnum] = curve_BP2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at a branch point found
% in a previous run. Called by coco as follows:
%   coco(opts, RUN, 'curve','BP','sol', RRUN, RLAB, PAR, PAR_INT)

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

% get tangent and parameter index at branch point
t1      = data.t;
acp_idx = data.acp_idx;

% compute vector 't2' normal to 't1' such that the plane spanned by 't1'
% and 't2' contains both branches approximately
[data J] = fdm_ezDFDX('f(o,d,x)', opts, data, data.TB_F, [x0;p0]);
JJ       = [ J(:,[data.x_idx data.x_idx(end)+acp_idx]) ; t1 ];
[X D]    = eig(JJ);
[v idx]  = min(abs(diag(D))); %#ok<ASGLU>
t2       = X(:,idx);
t2       = t2/norm(t2);

% compute initial point on new branch
[x0 p0] = computeFirstPoint(opts, data, x0, p0, t2);

% We pass the computed initial point to the constructor.
opts = curve_create(opts, f,fx,fp,T,Tp, x0, p0, q);

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end
