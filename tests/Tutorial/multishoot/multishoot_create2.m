function opts = multishoot_create2(opts, f, fx, fp, h, hx, hp, g, gx, gp, x0, p0, signature)
% Constructor of multiple shooting toolbox.

% initialise defaults
defaults.LP = 1;             % detect limit points
defaults.PD = 0;             % detect period-doubling points
defaults.NS = 0;             % detect Neimark-Sacker points
defaults.ParNames = {};      % descriptive parameter names
defaults.ODEsolver = @ode45; % use ode45 by default ode113 ode15s

copts = coco_get(opts, 'multishoot');
copts = coco_set(defaults, copts);

% initialise toolbox data structure
data.f     = f;
data.fx    = fx;
data.fp    = fp;
data.h     = h;
data.hx    = hx;
data.hp    = hp;
data.g     = g;
data.gx    = gx;
data.gp    = gp;
data.sig   = signature;
data.nseg  = numel(signature);
data.dim   = size(x0,1);
data.x_idx = 1:numel(x0);
data.p_idx = data.x_idx(end) + (1:numel(p0));
data.Jxrows = repmat(reshape(1:data.dim*data.nseg, [data.dim data.nseg]), [data.dim 1]);
data.Jxcols = repmat(1:data.dim*data.nseg, [data.dim 1]);
data.Jprows = repmat(reshape(1:data.dim*data.nseg, [data.dim data.nseg]), [numel(p0) 1]);
data.Jpcols = repmat(repmat(1:numel(p0), [data.dim 1]), [1 data.nseg]);

% initialise ode options
ode_opts = odeset('RelTol', 1.0e-4, 'AbsTol', 1.0e-6, 'NormControl', 'on');
data.ode_opts  = ode_opts;
data.ODEsolver = copts.ODEsolver;
[opts data.Jxidx] = coco_add_chart_data(opts, 'multishoot', [], []);
% create pointer to data to enable sharing data between
% several function
data_ptr = coco_ptr(data);

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'curve', @curve, data, 'zero', ...
  'x0', [ x0(:) ; p0 ], 'passchart', 'F+DF');

% define u(data.p_idx) as parameters
if isempty(copts.ParNames)
  % use default names 'PAR(...)'
  opts = coco_add_parameters(opts, '', data.p_idx, 1:numel(p0));
else
  % use names provided by user
  opts = coco_add_parameters(opts, '', data.p_idx, copts.ParNames);
end

% enable detection of bifurcation points
if copts.LP || copts.PD || copts.NS
  % add test function for limit points
  opts = coco_add_func(opts, 'curve_TF', @curve_TF, data_ptr, 'singular', ...
    {'test_LP' 'test_PD' 'test_NS' 'stab'}, 'passchart');
  
  if copts.LP
    % add event for zero crossing of test_LP
    opts = coco_add_event(opts, 'LP', 'test_LP', 0);
  end
    if copts.PD
    % add event for zero crossing of test_PD
      opts = coco_add_event(opts, 'PD', 'test_PD', 0);
    end
  if copts.NS
    % add event for zero crossing of test_NS
    opts = coco_add_event(opts, 'NS', 'test_NS', 0);
  end
    
end

% add slot function for adding data to bifurcation diagram, for additional
% screen output and for saving toolbox data at labeled solution points.
opts = coco_add_slot(opts, 'curve_bddat', @curve_bddat, ...
  data, 'bddat');
opts = coco_add_slot(opts, 'curve_print', @curve_print, ...
  data, 'cont_print');
opts = coco_add_slot(opts, 'curve_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');
end

function [data chart y J] = curve(opts, data, chart, u) %#ok<INUSL>
x   = reshape(u(data.x_idx), [data.dim data.nseg]);
p   = u(data.p_idx);
if nargout<4
    phi = multiple_shooting(data, x, p);
    y   = phi - circshift(x, [0 -1]);
    y   = y(:);
else
    [phi Jx Jp] = multiple_shooting_DFDU(data, x, p);
    y = phi - circshift(x, [0 -1]);
    y = y(:);
    J = [ sparse(data.Jxrows(:), data.Jxcols(:), Jx(:)) sparse(data.Jprows(:), data.Jpcols(:), Jp(:)) ];
    J = J - [ circshift(eye(numel(x),numel(x)),[0 data.dim]) zeros(numel(x),numel(p)) ];
    chart.data{data.Jxidx} = Jx;
end
end

function phi = multiple_shooting(data, x, p)
phi = x;
for i=1:data.nseg
    f = @(t,x) data.f(x, p, data.sig(i));
    h = @(t,x) data.h(x, p, data.sig(i));
    data.ode_opts = odeset(data.ode_opts, 'Events', h);
    ie = [];
    x0  = x(:,i);
    time = 0;
    while isempty(ie) && time<2*pi/p(5)
        [t y te ye ie] = data.ODEsolver(f, [0 1], x0, data.ode_opts); %#ok<ASGLU>
        x0  = y(end,:);
        time = time + 1;
    end
    phi(:,i) = data.g(x0, p, data.sig(i));
end
end

function [phi Jx Jp] = multiple_shooting_DFDU(data, x, p)
    function y = VarEQN2(data, p, m, n, xx, s)
        M  = reshape(xx(m+1:m*m+m), m, m);
        N  = reshape(xx(m*m+m+1:end), m, n);
        Fx = data.fx(xx(1:m)', p, s);
        Fp = data.fp(xx(1:m)', p, s);
        y  = [ data.f(xx(1:m)', p, s) Fx*M Fx*N+Fp ];
        y  = y(:);
    end
phi = x;
m  = data.dim;
n  = numel(p);
Jx = zeros(m, m, data.nseg);
Jp = zeros(m, n, data.nseg);
for i=1:data.nseg
    f  = @(t,M) VarEQN2(data, p, m, n, M, data.sig(i));
    h = @(t,M) data.h(M(1:m)', p, data.sig(i));
    data.ode_opts = odeset(data.ode_opts, 'Events', h);
    M0 = [x(:,i) eye(m,m+n)];
    ie = [];
    time = 0;
    while isempty(ie) && time<2*pi/p(5)
        [t y te ye ie] = data.ODEsolver(f, [0 1], M0(:), data.ode_opts); %#ok<ASGLU>
        M0 = y(end,:);
        time = time+1;
    end
    x0        = M0(1:m)';
    phi(:,i) = data.g(x0, p, data.sig(i));
    fs        = data.f(x0, p, data.sig(i));
    hx        = data.hx(x0, p, data.sig(i));
    hp        = data.hp(x0, p, data.sig(i));
    gx        = data.gx(x0, p, data.sig(i));
    gp        = data.gp(x0, p, data.sig(i));
    Jx(:,:,i) = gx*(eye(m,m)-fs*hx/(hx*fs))*reshape(M0(m+1:m*m+m), m, m);
    Jp(:,:,i) = gx*(eye(m,m)-fs*hx/(hx*fs))*reshape(M0(m*m+m+1:end), m, n)+gx*fs*hp/(hx*fs)+gp;
end
end

function [data_ptr chart y] = curve_TF(opts, data_ptr, chart, u)
% define test functions for limit points and branch points
% don't change this first part!
data     = data_ptr.data;
if isempty(chart.data{data.Jxidx})
    [data chart phi J] = curve(opts, data, chart, u);
end

% define additional test functions on eigenvalues.
Jx = chart.data{data.Jxidx};

J = eye(data.dim,data.dim);
for i=1:data.nseg
    J = Jx(:,:,i)*J;
end
v = eig(J);

y(1,1)     = prod(v-1);
y(end+1,1) = prod(v+1);

if numel(v)>1
  NS_TF = triu(kron(v, v.'),1) + tril(1+ones(numel(v)));
  y(end+1,1) = prod(NS_TF(:)-1);
else
  y(end+1,1) = 1;
end

y(end+1,1) = max(abs(v));

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