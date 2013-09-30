function [opts argnum] = curve_PD2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at a period-doubling
% point found in a previous run. Called by coco as follows:
%   coco(opts, RUN, 'curve','PD','sol', RRUN, RLAB, PAR, PAR_INT)

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
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% compute tangent vector at period-doubled branch and predict new initial
% point
Jx      = data.Jx;
[X D]   = eig(Jx);
[t idx] = min( abs(diag(D)+1) ); %#ok<ASGLU>
t0      = X(:,idx);
t0      = t0/norm(t0);

% compute initial guess
h = coco_get(opts, 'cont.h0');
if isstruct(h)
  h = 0.05;
else
  h = 0.5*h;
end
x0 = x0 + h*t0;
t0 = [t0 ; zeros(numel(p0),1)];

% switch branch
% 2: use PD-symmetry-function
% 3: use projection condition
% otherwise: use classical method
if copts.switch==2
  opts = curve_create(opts, f, x0, p0, 2*q, [],  1, []);
elseif copts.switch==3
  % we have to pass t0 here, because the test function itself uses t0
  opts = curve_create(opts, f, x0, p0, 2*q, t0, [],  1);
else
  opts = curve_create(opts, f, x0, p0, 2*q, t0, [], []);
end

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end
