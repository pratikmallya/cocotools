function opts = curve_create(opts, f, fx, fp, T, Tp, x0, p0, period)
% Constructor of toolbox curve. Called by parser functions of toolbox
% curve.

% initialise defaults
defaults.LP = 1;             % detect limit points
defaults.BP = 1;             % detect branch points
defaults.PD = 1;             % detect period-doubling points
defaults.NS = 1;             % detect Neimark-Sacker points
defaults.ParNames = {};      % descriptive parameter names
defaults.ODEsolver = @ode45; % use ode45 by default ode113 ode15s

copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% initialise toolbox data structure
data.f     = f;
data.fx    = fx;
data.fp    = fp;
data.T     = T;
data.Tp    = Tp;
data.q     = period;
data.x_idx = 1:numel(x0);
data.p_idx = data.x_idx(end) + (1:numel(p0));

% initialise ode options
ode_opts = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-8, 'NormControl', 'on');
data.ode_opts  = ode_opts;
data.ODEsolver = copts.ODEsolver;

% initialise data used by limit- and branch-point test function
data.t     = [];     % tangent vector at solution curve
data.TB_F  = @curve; % handle to actual zero-problem

% create pointer to data to enable sharing data between
% several function
data_ptr = coco_ptr(data);

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'curve', @curve, @curve_DFDU, data, 'zero', ...
  'x0', [ x0 ; p0 ]);

% define u(data.p_idx) as parameters
if isempty(copts.ParNames)
  % use default names 'PAR(...)'
  opts = coco_add_parameters(opts, '', data.p_idx, 1:numel(p0));
else
  % use names provided by user
  opts = coco_add_parameters(opts, '', data.p_idx, copts.ParNames);
end

% enable detection of bifurcation points
if copts.LP || copts.BP || copts.PD || copts.NS
  % add test function for limit points
  opts = coco_add_func(opts, 'curve_TF', @curve_TF, data_ptr, 'singular', ...
    {'test_LP' 'test_BP' 'test_PD' 'test_NS' 'stab' 'sym'});
  
  if copts.LP
    % add event for zero crossing of test_LP
    opts = coco_add_event(opts, 'LP', 'test_LP', 0);
  end
  if copts.BP
    % add event for zero crossing of test_BP
    opts = coco_add_event(opts, 'BP', 'test_BP', 0);
  end
  if copts.PD
    % add event for zero crossing of test_PD
    if copts.PD == 1
      opts = coco_add_event(opts, 'PD', 'test_PD', 0);
    else
      opts = coco_add_event(opts, 'PD', 'BP', 'test_PD', 0);
    end
  end
  if copts.NS
    % add event for zero crossing of test_NS
    opts = coco_add_event(opts, 'NS', 'test_NS', 0);
  end
    
  if copts.BP || copts.PD
    % add update event for BP test function and branch-switching
    opts = coco_add_slot(opts, 'curve_TF_update', @curve_TF_update, ...
      data_ptr, 'covering_update');
  end
end

% add call-back for adding data to bifurcation diagram
opts = coco_add_slot(opts, 'curve_bddat', @curve_bddat, ...
  data, 'bddat');

% add call-back for additional screen output
opts = coco_add_slot(opts, 'curve_print', @curve_print, ...
  data, 'cont_print');

% add call-back for saveing toolbox data at labelled solution points
opts = coco_add_slot(opts, 'curve_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');
end

function [data y] = curve(opts, data, u) %#ok<INUSL>
% define zero problem f^q(x,p)-x = 0
x = u(data.x_idx);
p = u(data.p_idx);
y = map_q(data, data.q, data.T(p), x, p) - x;
end

function [data J] = curve_DFDU(opts, data, u) %#ok<INUSL>
% define zero problem f^q(x,p)-x = 0
x = u(data.x_idx);
p = u(data.p_idx);
J = map_q_DFDU(data, data.q, data.T(p), x, p) - eye(numel(x),numel(u));
% [data J1] = fdm_ezDFDX('f(o,d,x)', opts, data, data.TB_F, [x;p]);
end

function [x xm] = map_q(data,q,T,x,p)
[t y] = data.ODEsolver(data.f, [0 q*0.5*T q*T], x, data.ode_opts, p); %#ok<ASGLU>
xm = y(2,:)';
x  = y(3,:)';
end

function [J x xm] = map_q_DFDX(data,q,T,x,p)
  function y = VarEQN1(data, t,p,m, xx)
    x  = xx(1:m);
    M  = reshape(xx(m+1:m*m+m), m,m);
    Jx = data.fx(t,x,p);
    y  = [ data.f(t,x,p) Jx*M ];
    y  = y(:);
  end
m     = numel(x);
f     = @(t,M) VarEQN1(data, t,p,m, M);
M0    = [x eye(m,m)];
[t M] = data.ODEsolver(f, [0 q*0.5*T q*T], M0(:), data.ode_opts); %#ok<ASGLU>
xm    = M(2,1:m)';
x     = M(3,1:m)';
M     = M(3,:);
J     = reshape(M(m+1:end), m,m);
end

function J = map_q_DFDU(data,q,T,x,p)
  function y = VarEQN2(data, t,p,m,n, xx)
    x  = xx(1:m);
    M  = reshape(xx(m+1:m*m+m), m,m);
    N  = reshape(xx(m*m+m+1:end), m, n-m);
    Jx = data.fx(t,x,p);
    Jp = data.fp(t,x,p);
    y  = [ data.f(t,x,p) Jx*M Jx*N+Jp ];
    y  = y(:);
  end
m     = numel(x);
n     = m + numel(p);
f     = @(t,M) VarEQN2(data, t,p,m,n, M);
M0    = [x eye(m,n)];
[t M] = data.ODEsolver(f, [0 q*0.5*T q*T], M0(:), data.ode_opts); %#ok<ASGLU>
M     = M(end,:);
J     = reshape(M(m+1:end), m,n);
JT    = [zeros(m,m) kron(data.f(0,M(1:m),p),data.Tp(p))];
J     = J+JT;
end

function [data_ptr y] = curve_TF(opts, data_ptr, u)
% define test functions for limit points and branch points
% don't change this first part!
data     = data_ptr.data;
% [data J] = fdm_ezDFDX('f(o,d,x)', opts, data, data.TB_F, ...
%   u([data.x_idx data.p_idx]));
[data J] = curve_DFDU(opts, data, u);
y(1,1)   = det(J(:,data.x_idx));
if isempty(data.t)
  y(2,1) = 1;
else
  JJ     = [ J(:,[data.x_idx data.x_idx(end)+data.acp_idx]) ; data.t ];
  y(2,1) = det(JJ);
end

% add your test functions here
% f = @(x,p) map_q(data, data.q, data.T(p), x, p);
% J = fdm_ezDFDX('f(x,p)', f, u(data.x_idx), u(data.p_idx));
x = u(data.x_idx);
p = u(data.p_idx);
[J x1 xm] = map_q_DFDX(data,data.q,data.T(p),x,p);
v = eig(J);

y(end+1,1) = prod(v+1);

if numel(v)>1
  NS_TF = triu(kron(v, v.'),1) + tril(1+ones(numel(v)));
  y(end+1,1) = prod(NS_TF(:)-1);
else
  y(end+1,1) = 1;
end

% stab = max(abs(v))-1;
% y(end+1,1) = (abs(stab)>1.0e-6)*sign(stab);
y(end+1,1) = max(abs(v));

sym = 0.5*(norm(x1-xm)+norm(xm-x));
y(end+1,1) = sym;

data_ptr.data = data;
end

function data_ptr = curve_TF_update(opts, data_ptr, cmd, varargin)
% Update tangent vector and index of active continuation parameter for test
% function for branch points.

data = data_ptr.data;

switch cmd
  case 'update'
    if ~isfield(data, 'acp_idx') || isempty(data.acp_idx)
      data.t       = varargin{2}';
      data.acp_idx = find(abs(data.t(data.p_idx))>opts.corr.TOL);
    end
    if ~isempty(data.acp_idx)
      data.t = varargin{2}';
      data.t = data.t([data.x_idx data.x_idx(end) + data.acp_idx]);
      data.t = data.t/norm(data.t);
    else
      data.t = [];
    end
    
  otherwise
end

data_ptr.data = data;
drawnow;

end

function [data res] = curve_bddat(opts, data, command, sol) %#ok<INUSL>
% add data to bifurcation diagram
switch command
  case 'init'
    res = { 'x' 'p' };
  case 'data'
    res = { sol.x(data.x_idx) sol.x(data.p_idx) };
end
end

function data = curve_print(opts, data, command, x) %#ok<INUSL>
% add data to screen output
switch command
  case 'init'
    fprintf('%10s', '||x||');
  case 'data'
    fprintf('%10.2e', norm(x(data.x_idx)));
end
end
