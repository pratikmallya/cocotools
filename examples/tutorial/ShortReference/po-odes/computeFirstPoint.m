function [x0 p0] = computeFirstPoint(opts1, data, x0, p0, t)
% compute initial point and initialise data structure
h = coco_get(opts1, 'cont.h0');
if isstruct(h)
  h = 0.001;
else
  h = 0.5*h;
end

if numel(t)==numel(x0)
  t  = [t;0];
end

acp_idx = data.acp_idx;
u0      = [x0;p0(acp_idx)];
u1      = u0 + h*t;
data.u0 = u0;
data.p0 = p0;
data.t  = t';

% use COCO to compute initial value
opts   = [];
opts   = coco_add_func(opts, 'F_switch', @F_switch, data, 'zero', ...
  'x0', [h;u1]);
opts   = coco_add_parameters(opts, '', 1, 'h');
opts   = coco_set(opts, 'cont', 'ItMX', [1 0]);
run    = [ coco_run_id(opts1) {'switch_init'} ];
coco(opts, run, [], 'h', [0 1]);

% load computed solution and copy new values for x and the active
% continuation parameter (all other parameters remain unchanged)
[dummy sol] = coco_read_solution('', run, 1); %#ok<ASGLU>
x0          = sol.x(1+data.x_idx);
p0(acp_idx) = sol.x(2+data.x_idx(end));
end

function [data y] = F_switch(opts, data, u)
% This function is quite complicated, because we use the actual zero
% problem, not the function f passed by the user. This is much simpler for
% branch-switching at period-doubling points.
h               = u(1);       % extract h
x               = u(2:end-1); % extract x
p               = data.p0;    % initialise parameters
p(data.acp_idx) = u(end);     % extract value of active parameter
u               = [x;p(data.acp_idx)]; % construct u for projection condition
[data y]        = data.TB_F(opts, data, [x;p]); % actual zero problem
y(end+1,1)      = data.t*(u-data.u0) - h;  % projection condition
end
