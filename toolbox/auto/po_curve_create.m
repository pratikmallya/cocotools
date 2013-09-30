function opts = po_curve_create(opts, f, fx, fp, g, gx, gp, h, hx, hp, ...
  x0, p0, T0, tx, tp, tT)

% get toolbox options
oopts = odeset('RelTol', 1.0e-4, 'AbsTol', 1.0e-6, 'NormControl', 'on');

defaults.ParNames  = {}    ; % descriptive parameter names
defaults.FP        = true  ; % detect fold points
defaults.BP        = true  ; % detect branch points
defaults.SN        = true  ; % detect saddle-node bifurcation points
defaults.PD        = true  ; % detect pure-dopple bifurcation points
defaults.NS        = true  ; % detect Neimark-Sacker bifurcation points
defaults.ODEsolver = @ode45; % use ode45 by default (other option: ode113)
defaults.ode_opts  = oopts ; % default set of ode options
copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% construct toolbox data as a pointer to enable sharing modifications to
% data between several functions
data.f       = f;
data.fx      = fx;
data.fp      = fp;
data.g       = g;
data.gx      = gx;
data.gp      = gp;
data.h       = h;
data.hx      = hx;
data.hp      = hp;
data.x_idx   = 1:numel(x0);
data.p_idx   = numel(x0) + (1:numel(p0));
data.T_idx   = numel(x0) + numel(p0) + 1;
data.ID      = eye(numel(data.x_idx));
data.rhs     = [ zeros(numel(x0),1) ; 0 ; 1 ];
data.acp_idx = 1;

data.ode_opts  = copts.ode_opts;
data.ODEsolver = copts.ODEsolver;

% save reference point and components of initial tangent
u0      = [x0;p0;T0];
data.x0 = x0;
data.f0 = data.f(x0,p0);
data.u0 = u0;
data.tx = tx;
data.tp = tp;
data.tT = tT;

% initialise t0
if isempty(tx)
  t0 = [];
  data.t = [zeros(size(x0));1;0];
elseif isempty(tp)
  t0 = [ tx ; zeros(numel(p0),1) ; 0 ];
  data.t = [tx;1;0];
elseif isempty(tT)
  t0 = [ tx ; tp ; 0 ];
  data.t = [tx;1;0];
else
  t0 = [ tx ; tp ; tT ];
  data.t = [tx;1;tT];
end

% construct index vectors for Neimark-Sacker test function
I            = triu(true(data.x_idx(end)-1),1);
A            = repmat(data.x_idx(1:end-1)', 1, data.x_idx(end)-1);
data.la_idx1 = A(I);
A            = A';
data.la_idx2 = A(I);

% end of initialisation
data_ptr = coco_ptr(data);

% combined index vector for adding monitor functions
xidx = [data.x_idx data.p_idx data.T_idx];

% add continuation problem (zero problem)
if isempty(fx) || isempty(fp)
  opts = coco_add_func(opts, 'curve', @curve, ...
    data, 'zero', 'x0', u0, 't0', t0 );
else
  opts = coco_add_func(opts, 'curve', @curve, @curve_DFDU, ...
    data, 'zero', 'x0', u0, 't0', t0 );
end

% define problem parameters
if isempty(copts.ParNames)
  opts = coco_add_parameters(opts, 'curve_pars', data.p_idx, 1:numel(p0));
else
  opts = coco_add_parameters(opts, 'curve_pars', data.p_idx, copts.ParNames);
end

% add monitor function if detection of bifurcations is requested
if copts.SN || copts.PD || copts.NS
  opts = coco_add_func(opts, 'test_regular', @curve_test_regular, ...
    data_ptr, 'regular', {'test_SN' 'test_PD' 'test_NS'}, 'xidx', xidx);
end
if copts.FP || copts.BP
  opts = coco_add_func(opts, 'test_singular', @curve_test_singular, ...
    data_ptr, 'singular', {'test_FP' 'test_BP'}, 'xidx', xidx);
end

% add events for bifurcation points
if copts.SN
  opts = coco_add_event(opts, 'SN', 'SP', 'test_SN', 0);
end
if copts.PD
  opts = coco_add_event(opts, 'PD', 'SP', 'test_PD', 0);
end
if copts.NS
  % opts = coco_add_event(opts, @evhan_NS, 'SP', 'test_NS', 0);
  opts = coco_add_event(opts, 'NS', 'SP', 'test_NS', 0);
end
if copts.FP
  opts = coco_add_event(opts, 'FP', 'SP', 'test_FP', 0);
end
if copts.BP
  opts = coco_add_event(opts, 'BP', 'SP', 'test_BP', 0);
end

% add more output to bifurcation diagram
opts = coco_add_slot(opts, 'curve_bddat', @curve_bddat, ...
  data_ptr, 'bddat');

% add more output to screen
opts = coco_add_slot(opts, 'curve_print', @curve_print, ...
  data_ptr, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_save', @curve_save, ...
  data_ptr, 'save_full');

% add slot function to update signal
opts = coco_add_slot(opts, 'curve_update', @curve_update, ...
  data_ptr, 'FSM_update');

% add slot function for initialising parts of toolbox data right before the
% continuation starts
opts = coco_add_slot(opts, 'curve_data_init', @curve_data_init, ...
  data_ptr, 'FSM_init_chart_begin');

end

function [data y] = curve(opts, data, u) %#ok<INUSL>
x0    = u(data.x_idx);
p     = u(data.p_idx);
T     = u(data.T_idx);
f     = @(t,x) data.f(x,p);
[t z] = data.ODEsolver(f,[0,T],x0,data.ode_opts); %#ok<ASGLU>
x1    = z(end,:)';
y     = [
  data.g(x1,p, data.x0,data.f0) - x0
  data.h(x1,p, data.x0,data.f0)
  ];
end

function [data J] = curve_DFDU(opts, data, u) %#ok<INUSL>
J = po_jacobian(data,u);
% [data J2] = fdm_ezDFDX('f(o,d,x)', opts, data, @curve, u);
%  figure(1);clf
%  spy(abs(J-J2) >1e-4)
end

function [data_ptr y] = curve_test_regular(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;

p      = u(data.p_idx);
[M x1] = po_var_sol(data, u);

% compute derivative of map and remove eigenvalue at 1
gx = data.gx(x1,p, data.x0,data.f0);
Jx = gx*M;
la = eig(Jx);
[minLa idx] = min(abs(la-1)); %#ok<ASGLU>
la(idx) = [];

% SN test function
la2    = la-1;
sc     = abs(la2);
la2    = (2*la2)./(max(1,sc)+sc);
y(1,1) = real(prod(la2));

% PD test function
la2    = la+1;
sc     = abs(la2);
la2    = (2*la2)./(max(1,sc)+sc);
y(2,1) = real(prod(la2));

% NS test function
la2    = la(data.la_idx1).*la(data.la_idx2)-1;
sc     = abs(la2);
la2    = (2*la2)./(max(1,sc)+sc);
y(3,1) = real(prod(la2));
end

function [ msg data ] = evhan_NS( opts, command, data )
% data = { u0 u1 e0 e1 scale h evidx pars pidx [check: x t] } + fields added here
% monitor functions: [opts p ] = opts.efunc.monitor_F(opts, data.x);
% event functions:   [opts ev] = opts.efunc.events_F (opts,      p);
% use ev(data.evidx)
switch command
  
  case 'init'
    if isfield(data, 'finish')
      msg.action = 'finish';
    else
      fdata_ptr = coco_get_func_data(opts, 'test_NS', 'data');
      fdata     = fdata_ptr.data;
      J1  = po_jacobian_test(fdata, data.u0);
      la1 = eig(J1);
      J2  = po_jacobian_test(fdata, data.u1);
      la2 = eig(J2);
      if sum(abs(la1)>1) == sum(abs(la2)>1)
        msg.point_type = 'NSad';
      else
        msg.point_type = 'NS';
      end
      msg.idx    = 1;
      msg.action = 'locate';
    end
    
  case 'check'
    % we accept all points if located successfully
    data.finish = true;
    msg.action  = 'add';
end
end

function [data_ptr y] = curve_test_singular(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;

J = po_jacobian(data, u, data.acp_idx);
A = [ J ; data.t' ];

% FP test function
t      = A\data.rhs;
y(1,1) = t(end-1);

% BP test function
la     = eig(A);
sc     = abs(la);
la     = (2*la)./(max(1,sc)+sc);
y(2,1) = prod(la);

end

function data_ptr = curve_update(opts, data_ptr, cmd, cseg, varargin)
data = data_ptr.data;
switch cmd
  case 'update'
    chart = cseg.base_chart;
    u = chart.x;
    t = chart.t;
    data.x0 = u(data.x_idx);
    data.f0 = data.f(data.x0,u(data.p_idx));
    if isfield(data, 't_idx')
      nt = norm(t(data.t_idx));
      % update only if the relevant part has large enough norm, this is
      % necessary because the first tangent may contain zeros there
      if nt>10*opts.corr.TOL
        data.t = t(data.t_idx)/nt;
      end
    end
end
data_ptr.data = data;
end

function [data_ptr res] = curve_bddat(opts, data_ptr, cmd, sol) %#ok<INUSL>
switch cmd
  case 'init'
    res = { 'x' 'p' '||x||' 'Period'};
  case 'data'
    data = data_ptr.data;
    x    = sol.x(data.x_idx);
    p    = sol.x(data.p_idx);
    T    = sol.x(data.T_idx);
    res  = { x, p, norm(x), T };
end
end

function [data_ptr res] = curve_save(opts, data_ptr, sol, varargin) %#ok<INUSL>

data = data_ptr.data;

switch sol.pt_type
  case {'PD' 'SN' 'NS'}
    p      = sol.x(data.p_idx);
    [M x1] = po_var_sol(data, sol.x);
    gx     = data.gx(x1,p, data.x0,data.f0);
    data.J = gx*M;
  case {'FP' 'BP'}
    J      = po_jacobian(data, sol.x, data.acp_idx);
    data.J = [ J ; data.t' ];
end

res = data;

end

function data_ptr = curve_print(opts, data_ptr, cmd, chart, u) %#ok<INUSL>
switch cmd
  case 'init'
    fprintf('%10s %10s', '||x||', 'Period');
  case 'data'
    data = data_ptr.data;
    fprintf('%10.2e %10.2e', norm(u(data.x_idx)), u(data.T_idx));
end
end

function data_ptr = curve_data_init(opts, data_ptr)
data          = data_ptr.data;

% compute the position of an active parameter in the combined u-vector
[xidx fidx]   = coco_get_func_data(opts, 'curve_pars', ...
  'xidx', 'fidx');
acp_idx  = intersect(opts.efunc.acp_f_idx, fidx);
for i=1:numel(acp_idx)
  acp_idx(i)  = xidx(acp_idx(i)==fidx);
end
acp_idx       = intersect(acp_idx, data.p_idx);
for i=1:numel(acp_idx)
  acp_idx(i)  = find(acp_idx(i)==data.p_idx);
end
data.acp_idx  = acp_idx(1);
data.t_idx    = [ data.x_idx data.p_idx(acp_idx(1)) data.T_idx ];

% the initialisations below are, in principle, not necessary,
% but they make some test functions smoother at the initial point
% compute approximate first tangent
u = data.u0;
A = [ po_jacobian(data, u, data.acp_idx) ; data.t' ];
if isempty(data.tx) || isempty(data.tp)
  data.t = A\data.rhs;
else
  data.t = [ data.tx ; data.tp(data.acp_idx) ; 0 ];
end
data.t = data.t/norm(data.t);

data_ptr.data = data;
end
