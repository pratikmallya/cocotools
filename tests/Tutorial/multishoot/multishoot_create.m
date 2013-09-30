function opts = multishoot_create(opts, ...
  f, fx, fp, h, hx, hp, g, gx, gp, update, ev_data, x0, pnames, p0, signature)
% Constructor of multiple shooting toolbox.

tbid = 'mshoot';

defaults.bifus     = false;  % detect bifurcation points
defaults.ODEsolver = @ode45; % use ode45 by default and define solver options
defaults.ode_opts  = odeset('RelTol', 1.0e-4, 'AbsTol', 1.0e-6, 'NormControl', 'on');

copts = coco_get(opts, tbid);
copts = coco_merge(defaults, copts);

fields = [ {
  'tbid' 'f' 'fx' 'fp' 'h' 'hx' 'hp' 'g' 'gx' 'gp'
  tbid   f   fx   fp   h   hx   hp   g   gx   gp  } {
  'update' 'ev_data' 'sig'
  update   ev_data   signature
  } ];
data        = struct(fields{:});
data.nseg   = numel(signature);
data.dim    = size(x0,1);
data.x_idx  = 1:numel(x0);
data.p_idx  = data.x_idx(end) + (1:numel(p0));
data.Jxrows = repmat(reshape(1:data.dim*data.nseg, [data.dim data.nseg]), [data.dim 1]);
data.Jxcols = repmat(1:data.dim*data.nseg, [data.dim 1]);
data.Jprows = repmat(reshape(1:data.dim*data.nseg, [data.dim data.nseg]), [numel(p0) 1]);
data.Jpcols = repmat(repmat(1:numel(p0), [data.dim 1]), [1 data.nseg]);

data.ode_opts  = copts.ode_opts;
data.ODEsolver = copts.ODEsolver;

data = coco_func_data(data);

opts = coco_add_func(opts, tbid, @mshoot, @mshoot_DFDU, data, 'zero', ...
  'x0', [ x0(:) ; p0 ]);

if ~isempty(pnames)
  pfid = coco_get_id(tbid, 'pars');
  opts = coco_add_pars(opts, pfid, data.p_idx, pnames);
end

if ~isempty(update)
  opts = coco_add_slot(opts, tbid, @mshoot_update, data, 'update');
end

if copts.bifus
  tfid = coco_get_id(tbid, 'TF');
  tfps = coco_get_id(tfid, {'LP' 'PD' 'NS' 'stab'});
  opts = coco_add_func(opts, tfid, @mshoot_TF, data, 'regular', tfps);
  opts = coco_add_event(opts, 'LP', tfps{1}, 0);
  opts = coco_add_event(opts, 'PD', tfps{2}, 0);
  opts = coco_add_event(opts, 'NS', tfps{3}, 0);
end

opts = coco_add_slot(opts, tbid, @coco_save_data, data, 'save_full');
end

function [data y] = mshoot(opts, data, u) %#ok<INUSL>
x   = reshape(u(data.x_idx), [data.dim data.nseg]);
p   = u(data.p_idx);
phi = multiple_shooting(data, x, p);
y   = phi - circshift(x, [0 -1]);
y   = y(:);
end

function [data J] = mshoot_DFDU(opts, data, u) %#ok<INUSL>
x       = reshape(u(data.x_idx), [data.dim data.nseg]);
p       = u(data.p_idx);
[Jx Jp] = multiple_shooting_DFDU(data, x, p);
J       = [ sparse(data.Jxrows(:), data.Jxcols(:), Jx(:)) sparse(data.Jprows(:), data.Jpcols(:), Jp(:)) ];
J       = J - [ circshift(eye(numel(x),numel(x)),[0 data.dim]) zeros(numel(x),numel(p)) ];
end

function phi = multiple_shooting(data, x, p)
phi = x;
for i=1:data.nseg
  f = @(t,x) data.f(x, p, data.sig(i));
  h = @(t,x) data.h(data.ev_data, x, p, data.sig(i));
  data.ode_opts = odeset(data.ode_opts, 'Events', h);
  ie   = [];
  x0   = x(:,i);
  time = 0;
  while isempty(ie)
    [t y te ye ie] = data.ODEsolver(f, [0 1], x0, data.ode_opts); %#ok<ASGLU>
    x0  = y(end,:);
    time = time + 1;
  end
  phi(:,i) = data.g(x0, p, data.sig(i));
end
end

function J = multiple_shooting_DFDX(data, x, p)
  function y = VarEQN1(data, p, m, xx, s)
    M  = reshape(xx(m+1:end), m, m);
    Jx = data.fx(xx(1:m), p, s);
    y  = [ data.f(xx(1:m), p, s) Jx*M ];
    y  = y(:);
  end
m = data.dim;
J = zeros(m, m, data.nseg);
for i=1:data.nseg
  f = @(t,M) VarEQN1(data, p, m, M, data.sig(i));
  h = @(t,M) data.h(data.ev_data, M(1:m), p, data.sig(i));
  data.ode_opts = odeset(data.ode_opts, 'Events', h);
  M0   = [x(:,i) eye(m,m)];
  ie   = [];
  time = 0;
  while isempty(ie)
    [t y te ye ie] = data.ODEsolver(f, [0 1], M0(:), data.ode_opts); %#ok<ASGLU>
    M0 = y(end,:);
    time = time+1;
  end
  x0       = M0(1:m)';
  fs       = data.f(x0, p, data.sig(i));
  hx       = data.hx(data.ev_data, x0, p, data.sig(i));
  gx       = data.gx(x0, p, data.sig(i));
  J(:,:,i) = gx*(eye(m,m)-fs*hx/(hx*fs))*reshape(M0(m+1:end), m, m);
end
end

function [Jx Jp] = multiple_shooting_DFDU(data, x, p)
  function y = VarEQN2(data, p, m, n, xx, s)
    M  = reshape(xx(m+1:m*m+m), m, m);
    N  = reshape(xx(m*m+m+1:end), m, n);
    Fx = data.fx(xx(1:m), p, s);
    Fp = data.fp(xx(1:m), p, s);
    y  = [ data.f(xx(1:m), p, s) Fx*M Fx*N+Fp ];
    y  = y(:);
  end
m  = data.dim;
n  = numel(p);
Jx = zeros(m, m, data.nseg);
Jp = zeros(m, n, data.nseg);
for i=1:data.nseg
  f  = @(t,M) VarEQN2(data, p, m, n, M, data.sig(i));
  h = @(t,M) data.h(data.ev_data, M(1:m), p, data.sig(i));
  data.ode_opts = odeset(data.ode_opts, 'Events', h);
  M0 = [x(:,i) eye(m,m+n)];
  ie = [];
  time = 0;
  while isempty(ie)
    [t y te ye ie] = data.ODEsolver(f, [0 1], M0(:), data.ode_opts); %#ok<ASGLU>
    M0 = y(end,:);
    time = time+1;
  end
  x0        = M0(1:m)';
  fs        = data.f(x0, p, data.sig(i));
  hx        = data.hx(data.ev_data, x0, p, data.sig(i));
  hp        = data.hp(data.ev_data, x0, p, data.sig(i));
  gx        = data.gx(x0, p, data.sig(i));
  gp        = data.gp(x0, p, data.sig(i));
  Jx(:,:,i) = gx*(eye(m,m)-fs*hx/(hx*fs))*reshape(M0(m+1:m*m+m), m, m);
  Jp(:,:,i) = gx*(eye(m,m)-fs*hx/(hx*fs))*reshape(M0(m*m+m+1:end), m, n)+gx*fs*hp/(hx*fs)+gp;
end
end

function [data y] = mshoot_TF(opts, data, u)
% define test functions on eigenvalues
% note that trivial multiplier is projected onto 0
x = reshape(u(data.x_idx), [data.dim data.nseg]);
p = u(data.p_idx);
Jx = multiple_shooting_DFDX(data, x, p);
J = eye(data.dim,data.dim);
for i=1:data.nseg
  J = Jx(:,:,i)*J;
end
v = eig(J);

y(1,1) = prod(v-1); % saddle-nodes
y(2,1) = prod(v+1); % period doublings

if numel(v)>1
  NS_TF = triu(kron(v, v.'),1) + tril(1+ones(numel(v)));
  y(3,1) = prod(NS_TF(:)-1); % Neimark-Sacker points
else
  y(3,1) = 1;
end

y(4,1) = max(abs(v)); % stability indicator
end

function data = mshoot_update(prob, data, cseg, varargin)
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
u    = cseg.src_chart.x(uidx);
x    = reshape(u(data.x_idx), [data.dim data.nseg]);
p    = u(data.p_idx);
data.ev_data = data.update(data.ev_data, x, p, data.sig);
end
