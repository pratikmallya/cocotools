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
data.t2  = t2';

% use COCO to compute initial value
h       = 0.01;
u0      = [x0;p0(acp_idx)];
u1      = u0 + h*t2;
data.u0 = u0;
data.p0 = p0;
opts1   = [];
opts1   = coco_add_func(opts1, 'BP_switch', @BP_switch, data, 'zero', ...
  'x0', [h;u1]);
opts1   = coco_add_parameters(opts1, '', 1, 'h');
opts1   = coco_set(opts1, 'cont', 'ItMX', [1 0]);
run     = [ coco_run_id(opts) {'BPinit'} ];
coco(opts1, run, [], 'h', [0 1]);

% load computed solution and copy new values for x and the active
% continuation parameter (all other parameters remain unchanged)
[dummy sol] = coco_read_solution('', run, 1); %#ok<ASGLU>
x0          = sol.x(1+data.x_idx);
p0(acp_idx) = sol.x(1+data.p_idx(acp_idx));

% We pass the computed initial point to the constructor.
opts = curve_create(opts, f, x0, p0);

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end

function [data y] = BP_switch(opts, data, u)
% This function is quite complicated, because we use the actual zero
% problem, not the function f passed by the user. This is much simpler for
% branch-switching at period-doubling points.
h               = u(1);       % extract h
x               = u(2:end-1); % extract x
p               = data.p0;    % initialise parameters
p(data.acp_idx) = u(end);     % extract value of active parameter
u               = [x;p];      % construct u for zero problem of toolbox
[data y]        = data.TB_F(opts, data, u); % actual zero problem
y(end+1,1)      = data.t2*(u-data.u0) - h;  % projection condition
end
