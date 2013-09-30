function demo_tanh

N = 20;

opts = coco_prob();

% add toolbox for simple interpolation problem
% opts = interp_create(opts, N, 0.1, 1);
% opts = interp_create(opts, N, 1, 1);
%opts = interp_create(opts, N, 0.2, 1);
opts = interp_create(opts, N, 0.2, 5);
% opts = interp_create(opts, N, 0.2, 15);

% add toolbox for simple boundary condition
opts = bc_create(opts);

% add some events to parameters mu and u1
opts = coco_add_event(opts, 'UZ', 'mu', 1:2:15);
opts = coco_add_event(opts, 'UZ', 'u1', 1:2:15);

opts = coco_set(opts, 'cont', 'NPR', 10);
% opts = coco_set(opts, 'cont', 'ItMX', 3);
opts = coco_set(opts, 'cont', 'NAdapt', 1);
opts = coco_set(opts, 'cont', 'LogLevel', 3);

% run continuation, name branch '1'
bd = coco(opts, '1', [], {'mu' 'u1'}, [1 15]);

% plot profiles
idx = coco_bd_idxs(bd, 'UZ');
u   = coco_bd_col(bd, 'u');
t   = coco_bd_col(bd, 't');
p   = coco_bd_col(bd, 'mu');
clf
if iscell(u)
  subplot(2,1,1);
  C = [ t(idx)' ; u(idx)' ];
  plot(C{:}, 'Marker', '.')
  subplot(2,1,2)
  NN = cellfun('size', u, 1);
  plot(p,NN)
else
  plot(t(:,idx), u(:,idx), 'Marker', '.')
end

%% this part is not so fancy
return %#ok<*UNRCH>
% run continuation, name branch '2'
bd = coco(opts, '2', [], {'u1' 'mu'}, [1 15]);

% plot profiles
idx = coco_bd_idxs(bd, 'UZ');
u   = coco_bd_col(bd, 'u');
t   = coco_bd_col(bd, 't');
p   = coco_bd_col(bd, 'u1');
clf
if iscell(u)
  subplot(2,1,1);
  C = [ t(idx)' ; u(idx)' ];
  plot(C{:}, 'Marker', '.')
  subplot(2,1,2)
  NN = cellfun('size', u, 1);
  plot(p,NN)
else
  plot(t(:,idx), u(:,idx), 'Marker', '.')
end

end

%% interpolation toolbox
function opts = interp_create(opts, N, s, p0)

data.N     = N;
data.t     = linspace(-1,1,N)';
shdata.th  = data.t;
data.s     = s;
data.xtr   = zeros(N+1,1);
data.xtr([1 N N+1 N+2]) = [1 N N+1 N+2];
data.x_idx = 1:N;
data.s_idx = data.x_idx(end)+1;
data.p_idx = data.s_idx(end)+1;

data = coco_func_data(data,shdata);

u0 = tanh(data.t);
s0 = 1;

% add zero problem
opts = coco_add_func(opts, 'tanh', @tanh_F, data, ...
  'zero', 'x0', [u0;s0;p0], 'ReMesh', @tanh_remesh );

% define parameters of zero problem
opts = coco_add_pars(opts, 'interp_pars', data.p_idx, 'mu');

% add x to bifurcation diagram
opts = coco_add_slot(opts, 'tanh_bddat', @tanh_bddat, data, 'bddat');
end

function [data y] = tanh_F(opts, data, u) %#ok<INUSL>
pr = data.pr;
y = u(pr.x_idx)-u(pr.s_idx)*tanh(u(pr.p_idx)*pr.t);
end

function [opts status xtr] = tanh_remesh(opts, data, ...
  chart, old_x, old_V) %#ok<INUSL>

u = old_x(data.x_idx);
V = old_V(data.x_idx,:);

uu = 2*(u-u(1))/(u(end)-u(1))-1 + data.s*data.t;
uu = 2*(uu-uu(1))/(uu(end)-uu(1))-1;
t0 = interp1(uu,data.t,data.th, 'cubic');
u0 = [ interp1(data.t,u,t0, 'cubic') ; old_x([data.s_idx data.p_idx]) ];
V0 = [ interp1(data.t,V,t0, 'cubic') ; old_V([data.s_idx data.p_idx],:) ];

if numel(data.t)==numel(t0)
  xtr = data.xtr;
  N   = data.N;
else
  N = numel(t0);
  xtr = data.xtr;
  xtr([end-2 end-1 end]) = [N N+1 N+2];
  data.xtr = zeros(N+2,1);
  data.xtr([1 N N+1 N+2]) = [1 N N+1 N+2];
  data.N     = N;
  data.x_idx = 1:N;
  data.s_idx = data.x_idx(end)+1;
  data.p_idx = data.s_idx(end)+1;
end

data.t = t0;

opts   = coco_change_func(opts, data, 'x0', u0, 'vecs', V0);
status = 'success';

coco_log(opts, 1, 1, '%s: remeshed, N=%d, status=''%s''\n', ...
  mfilename, N, status);
end

function [data res] = tanh_bddat(opts, data, command, sol) %#ok<INUSL>
switch command
  case 'init'
    res = { 'u' 't' };
  case 'data'
    res = { sol.x(data.x_idx) data.t };
end
end

function opts = bc_create(opts)
[data xidx] = coco_get_func_data(opts, 'tanh', 'data', 'xidx');
u1idx = xidx(data.x_idx(end));

% add boundary condition
opts = coco_add_func(opts, 'tanh_bc', @tanh_bc_F, [], ...
  'zero', 'xidx', u1idx, 'x0', 1, 'ReMesh', @bc_remesh );

% define parameters of zero problem
xidx = coco_get_func_data(opts, 'tanh_bc', 'xidx');
opts = coco_add_pars(opts, 'bc_pars', xidx(2), 'u1');
end

function [data y] = tanh_bc_F(opts, data, u) %#ok<INUSL>
y = u(1)-u(2);
end

function [opts status xtr] = bc_remesh(opts, data, ...
  chart, old_x, old_V) %#ok<INUSL>

[fdata xidx] = coco_get_func_data(opts, 'tanh', 'data', 'xidx');
u1idx = xidx(fdata.x_idx(end));

u0     = old_x(2);
V0     = old_V(2,:);
opts   = coco_change_func(opts, [], 'xidx', u1idx, 'x0', u0, 'vecs', V0);
status = 'success';
xtr    = 1;

t = fdata.t;
H = max(abs(diff(t)));
coco_log(opts, 1, 1, '%s: H = % .10e\n', mfilename, H);
N = numel(fdata.th);
if H>0.3
  fac = min((H/0.2), 1.1); % add at least 10% mesh points
  N2  = min(100, ceil(N*fac));
elseif H<0.2
  fac = max((H/0.2), 0.75); % remove at most 25% mesh points
  N2  = max(10, ceil(N*fac));
else
  N2 = N;
end
if N~=N2
  fdata.th = linspace(-1,1,N2)';
  status = 'repeat';
end

coco_log(opts, 1, 1, '%s: remeshed, N=%d, N2=%d, status=''%s''\n', ...
  mfilename, N, N2, status);

end
