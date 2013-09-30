function opts = curve_create(opts, f, x0, p0, period, t0, t1, t2)
% Constructor of toolbox curve. Called by parser functions of toolbox
% curve.

% initialise defaults
defaults.LP = 1;        % detect limit points
defaults.BP = 1;        % detect branch points
defaults.PD = 1;        % detect period-doubling points
defaults.NS = 1;        % detect Neimark-Sacker points
defaults.ParNames = {}; % descriptive parameter names

copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% initialise toolbox data structure
data.f      = f;
data.q      = period;
data.x_idx  = 1:numel(x0);
data.p_idx  = data.x_idx(end) + (1:numel(p0));
data.xp_idx = [ data.x_idx data.p_idx ];
data.t0     = t0;
data        = curve_set_t(data, t0);

% create pointer to data to enable sharing data between
% several function
data_ptr = coco_ptr(data);

% add continuation problem (zero problem)
if isempty(t2)
  opts = coco_add_func(opts, 'curve', @curve, data, 'zero', ...
    'x0', [ x0 ; p0 ], 't0', t0);
else
  opts = coco_add_func(opts, 'curve', @curve, data, 'zero', ...
    'x0', [ x0 ; p0 ]);
end

% define u(data.p_idx) as parameters
if isempty(copts.ParNames)
  % use default names 'PAR(...)'
  opts = coco_add_parameters(opts, '', data.p_idx, 1:numel(p0));
else
  % use names provided by user
  opts = coco_add_parameters(opts, '', data.p_idx, copts.ParNames);
end

% add symmetry and projection monitor functions
opts = coco_add_func(opts, 'curve_POSym', @curve_POSym, data, ...
  'active', 'POSym', 't0', t1);
opts = coco_add_func(opts, 'curve_PRCnd', @curve_PRCnd, data, ...
  'active', 'PRCnd', 't0', t2);

% enable detection of bifurcation points
if copts.LP || copts.BP || copts.PD || copts.NS
  % add test function for limit points
  opts = coco_add_func(opts, 'curve_TF', @curve_TF, data_ptr, 'singular', ...
    {'test_LP' 'test_BP' 'test_PD' 'test_NS'});
  
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
      opts = coco_add_event(opts, 'PH', 'POSym', 0);
    else
      opts = coco_add_event(opts, 'PD', 'BP', 'test_PD', 0);
      opts = coco_add_event(opts, 'PH', 'BP', 'POSym', 0);
    end
  end
  if copts.NS
    % add event for zero crossing of test_NS
    opts = coco_add_event(opts, 'NS', 'test_NS', 0);
  end
    
  % add update event
  opts = coco_add_slot(opts, 'curve_TF_update', @curve_TF_update, ...
    data_ptr, 'covering_update');
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
y = map_q(data.f, data.q, x, u(data.p_idx)) - x;
end

function x = map_q(f,q,x,p)
for i=1:q
  x = f(x,p);
end
end

function [data_ptr y] = curve_TF(opts, data_ptr, u) %#ok<INUSL>
% define test functions for limit points and branch points
% don't change this first part!
data     = data_ptr.data;

f    = @(x,p) map_q(data.f, data.q, x, p);
x    = u(data.x_idx);
p    = u(data.p_idx);
pidx = 1:numel(p);
Jx   = fdm_ezDFDX('f(x,p)', f, x, p);
Jp   = fdm_ezDFDP('f(x,p)', f, x, p, pidx);
if isempty(data.tn)
  JJ = [];
else
  JJ   = [
    Jx - eye(numel(x))  Jp*data.tn
    data.tx'            data.tp'*data.tn
    ];
end

% save matrices for restart parser
data.Jx = Jx;
data.Jp = Jp;
data.JJ = JJ;

% limit- and branch-points
if isempty(JJ)
  y = nan(2,1);
else
  y(2,1) = det(JJ);
  if abs(y(2,1))>1.0e-8
    t = JJ\[zeros(numel(x),1) ; 1];
    y(1,1) = t(end);
  else
    y(1,1) = 0;
  end
  
end

% period-doubling and Neimark-Sacker
v = eig(Jx);

y(end+1,1) = prod(v+1);

if numel(v)>1
  NS_TF = triu(kron(v, v.'),1);
  y(end+1,1) = prod(NS_TF(:)-1);
else
  y(end+1) = 1;
end

data_ptr.data = data;
end

function [data y] = curve_POSym(opts, data, u) %#ok<INUSL>
% symmetry function ||f^(q/2)(x,p)-x||
if data.q>1
  x = u(data.x_idx);
  y = map_q(data.f, data.q/2, x, u(data.p_idx)) - x;
  y = y'*y;
else
  y = 0;
end
end

function [data y] = curve_PRCnd(opts, data, u) %#ok<INUSL>
% projection condition t'*x = h
if isempty(data.t0)
  y = 0;
else
  y = data.t0(data.x_idx)'*u(data.x_idx);
end
end

function data = curve_set_t(data, t)
if isempty(t)
  data.t  = [];
  data.tx = [];
  data.tp = [];
  data.tn = [];
else
  data.t  = t(data.xp_idx,:);
  data.tx = t(data.x_idx,:);
  data.tp = t(data.p_idx,:);
  if norm(data.tp)>10*eps
    ntp     = sqrt(sum(data.tp.*data.tp,1));
    o       = ones(size(data.tp,1),1);
    data.tn = data.tp./ntp(o,:);
  else
    data.tn = 0*data.tp;
  end
end
end

function data_ptr = curve_TF_update(opts, data_ptr, cmd, varargin) %#ok<INUSL>
% Update tangent vector and index of active continuation parameter for test
% function for branch points.

data = data_ptr.data;

switch cmd
  case 'update'
    data = curve_set_t(data, varargin{2});
    
  otherwise
end

data_ptr.data = data;

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
