function opts = fp_curve_create(opts, f, fx, fp, x0, p0, k, tx, tp)

% get toolbox options
defaults.ParNames = {}        ; % descriptive parameter names
defaults.FP       = true      ; % detect fold points
defaults.BP       = true      ; % detect branch points
defaults.SN       = true      ; % detect saddle-node bifurcation points
defaults.PD       = true      ; % detect pure-dopple bifurcation points
defaults.NS       = true      ; % detect Neimark-Sacker bifurcation points
copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% construct toolbox data as a pointer to enable sharing modifications to
% data between several functions
data.f       = f;
data.fx      = fx;
data.fp      = fp;
data.x_idx   = 1:numel(x0);
data.p_idx   = numel(x0) + (1:numel(p0));
data.k       = k;
data.ID      = eye(numel(data.x_idx));
data.rhs     = [ zeros(numel(x0),1) ; 1 ];
data.acp_idx = 1;

% save reference point and components of initial tangent
u0      = [x0;p0];
data.u0 = u0;
data.tx = tx;
data.tp = tp;

% initialise t0
if isempty(tx)
  t0 = [];
  data.t = [zeros(size(x0));1];
elseif isempty(tp)
  t0 = [ tx ; zeros(numel(p0),1) ];
  data.t = [tx;1];
else
  t0 = [ tx ; tp ];
  data.t = [tx;1];
end

% construct index vectors for Neimark-Sacker test function
I            = triu(true(data.x_idx(end)),1);
A            = repmat(data.x_idx', 1, data.x_idx(end));
data.la_idx1 = A(I);
A            = A';
data.la_idx2 = A(I);

% end of initialisation
data_ptr = coco_ptr(data);

% combined index vector for adding monitor functions
xidx = [data.x_idx data.p_idx];

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

% add monitor function for NS points
if copts.NS
  opts = coco_add_func(opts, 'test_NS', @test_NS, ...
    data_ptr, 'regular', 'test_NS', 'xidx', xidx);
  opts = coco_add_event(opts, @evhan_NS, 'SP', 'test_NS', 0);
end

% add monitor function for saddle-node points
if copts.SN
  opts = coco_add_func(opts, 'test_SN', @test_SN, ...
    data_ptr, 'regular', 'test_SN', 'xidx', xidx);
  opts = coco_add_event(opts, 'SN', 'SP', 'test_SN', 0);
end

% add monitor function for period-double points
if copts.PD
  opts = coco_add_func(opts, 'test_PD', @test_PD, ...
    data_ptr, 'regular', 'test_PD', 'xidx', xidx);
  opts = coco_add_event(opts, 'PD', 'SP', 'test_PD', 0);
end

% add monitor function for folds
if copts.FP
  opts = coco_add_func(opts, 'test_FP', @test_FP, ...
    data_ptr, 'regular', 'test_FP', 'xidx', xidx);
  opts = coco_add_event(opts, 'FP', 'SP', 'test_FP', 0);
end

% add monitor function for branch points
if copts.BP
  opts = coco_add_func(opts, 'test_BP', @test_BP, ...
    data_ptr, 'singular', 'test_BP', 'xidx', xidx);
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
  data_ptr, 'fsm_bcb_init');

end

function [data y] = curve(opts, data, u) %#ok<INUSL>
x = u(data.x_idx);
p = u(data.p_idx);
for j = 1:data.k
  x = data.f(x,p);
end
y = x-u(data.x_idx);
end

function [data J] = curve_DFDU(opts, data, u) %#ok<INUSL>
x  = u(data.x_idx);
p  = u(data.p_idx);
fp = data.fp;
fx = data.fx;
f  = data.f;

Jx = fx(x,p);
Jp = fp(x,p);
if(data.k > 1)
  for j=1:data.k-1
    x  = f(x,p);
    J  = fx(x,p);
    Jx = J*Jx;
    Jp = J*Jp+fp(x,p);
  end
end
J = [Jx-data.ID Jp];

% [data J2] = fdm_ezDFDX('f(o,d,x)', opts, data, @curve, u);
%  figure(1);clf
%  spy(abs(J-J2) >1e-4)
end


function [data_ptr y] = test_NS(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J  = fp_jacobian(data, u);
la = eig(J);
la = la(data.la_idx1).*la(data.la_idx2)-1;
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = real(prod(la));
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
      J1  = fp_jacobian(fdata, data.u0);
      la1 = eig(J1);
      J2  = fp_jacobian(fdata, data.u1);
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

function [data_ptr y] = test_SN(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J  = fp_jacobian(data, u);
la = eig(J)-1;
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = prod(la);
end

function [data_ptr y] = test_PD(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J  = fp_jacobian(data, u);
la = eig(J)+1;
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = prod(la);
end

function [data_ptr y] = test_FP(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J = fp_jacobian(data, u);
b = fp_par_deriv(data, u, data.acp_idx);
A = [J-data.ID b; data.t'];
t = A\data.rhs;
y = t(end);
end

function [data_ptr y] = test_BP(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J  = fp_jacobian(data, u);
b  = fp_par_deriv(data, u, data.acp_idx);
A  = [J-data.ID b; data.t'];
la = eig(A);
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = prod(la);
end

function data_ptr = curve_update(opts, data_ptr, cmd, u, t, varargin) %#ok<INUSL>
data = data_ptr.data;
switch cmd
  case 'update'
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
    res = { 'x' 'p' '||x||' };
  case 'data'
    data = data_ptr.data;
    x    = sol.x(data.x_idx);
    p    = sol.x(data.p_idx);
    res  = { x, p, norm(x) };
end
end

function [data_ptr res] = curve_save(opts, data_ptr, sol, varargin) %#ok<INUSL>

data = data_ptr.data;

switch sol.pt_type
  case {'PD' 'SN' 'FP' 'NS'}
    data.J = fp_jacobian(data, sol.x);
  case 'BP'
    J      = fp_jacobian (data, sol.x);
    b      = fp_par_deriv(data, sol.x, data.acp_idx);
    A      = [J-data.ID b; data.t'];
    data.J = A;
end

res = data;

end

function data_ptr = curve_print(opts, data_ptr, cmd, u) %#ok<INUSL>
switch cmd
  case 'init'
    fprintf('%10s', '||x||');
  case 'data'
    data = data_ptr.data;
    fprintf('%10.2e', norm(u(data.x_idx)));
end
end

function data_ptr = curve_data_init(opts, data_ptr)
data          = data_ptr.data;

% compute the position of an active parameter in the combined u-vector
[xidx fidx]   = coco_get_func_data(opts, 'curve_pars.parameters', ...
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
data.t_idx    = [ data.x_idx data.p_idx(acp_idx(1)) ];

% the initialisations below are, in principle, not necessary,
% but they make some test functions smoother at the initial point
% compute approximate first tangent
u = data.u0;
J = fp_jacobian(data, u);
if isempty(data.tx) || isempty(data.tp)
  b      = fp_par_deriv(data, u, data.acp_idx);
  data.t = [-(J-data.ID)\b; 1];
else
  data.t = [ data.tx ; data.tp(data.acp_idx) ];
end
data.t = data.t/norm(data.t);

data_ptr.data = data;
end
