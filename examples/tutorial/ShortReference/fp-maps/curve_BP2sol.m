function [opts argnum] = curve_BP2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at a branch point found
% in a previous run. Called by coco as follows:
%   coco(opts, RUN, 'curve','BP','sol', RRUN, RLAB, PAR, PAR_INT)

% In principle, this function could handle more arguments for
% user-friendliness, or perform some error-tests.

% initialise defaults
defaults.switch = 1; % branch-switching method

copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
q  = data.q;
t  = data.t;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% compute vector 't2' normal to 't1=data.t' such that the plane spanned by 't1'
% and 't2' contains both branches approximately
JJ             = data.JJ;
[X D]          = eig(JJ);
[v idx]        = min(abs(diag(D))); %#ok<ASGLU>
t2             = X(:,idx);
t2             = t2/norm(t2);
t2(data.p_idx) = t2(end)*t(data.p_idx);

% compute initial guess
h = coco_get(opts, 'cont.h0');
if isstruct(h)
  h = 0.05;
else
  h = 0.5*h;
end
x0 = x0 + h*t2(data.x_idx);
p0 = p0 + h*t2(data.p_idx);

% switch branch
% 3: use projection condition
% otherwise: use classical method
if copts.switch==3
  opts = curve_create(opts, f, x0, p0, q, t2, [],  1);
else
  opts = curve_create(opts, f, x0, p0, q, t2, [], []);
end

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end
