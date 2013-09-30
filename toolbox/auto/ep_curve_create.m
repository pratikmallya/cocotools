function opts = ep_curve_create(opts, f, fx, fp, x0, p0, tx, tp)

% get toolbox options
defaults.ParNames = {}        ; % descriptive parameter names
defaults.FP       = true      ; % detect fold points
defaults.FPTF     = 'tangent' ; % fold point test function
defaults.BP       = true      ; % detect branch points
defaults.SN       = true      ; % detect saddle-node bifurcation points
defaults.HB       = true      ; % detect saddle-node bifurcation points
copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% construct toolbox data as a pointer to enable sharing modifications to
% data between several functions
data.f       = f;
data.fx      = fx;
data.fp      = fp;
data.x_idx   = 1:numel(x0);
data.p_idx   = numel(x0) + (1:numel(p0));

% save reference point and components of initial tangent
u0      = [x0;p0];
data.u0 = u0;
data.tx = tx;
data.tp = tp;

% initialise t0
if isempty(tx)
  t0 = [];
elseif isempty(tp)
  t0 = [ tx ; zeros(numel(p0),1) ];
else
  t0 = [ tx ; tp ];
end

% initialise bordering vectors for extended systems as left- and right
% eigenvectors for smallest eigenvalue
J          = jacobian(data, u0);

if issparse(J)
  data.b = rand(numel(x0),1);
  data.c = rand(1,numel(x0));
else
  [X D]      = eig(J);
  [eval idx] = min(abs(diag(D))); %#ok<ASGLU>
  b          = X(:,idx);
  if norm(real(b)) >= norm(imag(b))
    data.b   = real(b);
  else
    data.b   = imag(b);
  end
  data.b     = data.b/norm(data.b);
  
  [X D]      = eig(J');
  [eval idx] = min(abs(diag(D))); %#ok<ASGLU>
  c          = X(:,idx);
  if norm(real(c)) >= norm(imag(c))
    data.c   = real(c)';
  else
    data.c   = imag(c)';
  end
  data.c     = data.c/norm(data.c);
end

data.d     = 0;
data.rhs   = [ zeros(numel(x0),1) ; 1 ];

data.update_borders = false;

% initialise tangent to guarantee regular bordered matrix at initial point
data.acp_idx = 1;
if isempty(tx)
  data.t = [ data.b ; 1 ];
else
  data.t = [ tx ; 1 ];
end
% construct index vectors for Hopf test function
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

% add monitor function for Hopf points
if copts.HB
  opts = coco_add_func(opts, 'test_HB', @test_HB, ...
    data_ptr, 'regular', 'test_HB', 'xidx', xidx);
  % opts = coco_add_event(opts, @evhan_HB, 'SP', 'test_HB', 0);
  opts = coco_add_event(opts, 'HB', 'SP', 'test_HB', 0);
end

% add monitor function for saddle-node points
if copts.SN
  opts = coco_add_func(opts, 'test_SN', @test_SN, ...
    data_ptr, 'regular', 'test_SN', 'xidx', xidx);
  opts = coco_add_event(opts, 'SN', 'SP', 'test_SN', 0);
end

% add monitor function for folds
if copts.FP
  switch lower(copts.FPTF)
    case 'tangent'
      opts = coco_add_func(opts, 'test_FP', @test_FP_tan, ...
        data_ptr, 'regular', 'test_FP', 'xidx', xidx);
    case 'determinant'
      opts = coco_add_func(opts, 'test_FP', @test_SN, ...
        data_ptr, 'regular', 'test_FP', 'xidx', xidx);
    case {'extended' 'minimally extended'}
      opts = coco_add_func(opts, 'test_FP', @test_FP_ext, ...
        data_ptr, 'regular', 'test_FP', 'xidx', xidx);
      data_ptr.data.update_borders = true;
    case {'extended active' 'minimally extended active'}
      opts = coco_add_func(opts, 'test_FP', @test_FP_ext, @test_FP_ext_DFDU, ...
        data_ptr, 'active', 'test_FP', 'xidx', xidx);
      data_ptr.data.update_borders = true;
    otherwise
      error('%s: unrecognised test function type ''%s''', ...
        mfilename, copts.FPTF);
  end
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
  data_ptr, 'FSM_init_chart_begin');

end

function [data y] = curve(opts, data, u) %#ok<INUSL>
y = data.f(u(data.x_idx), u(data.p_idx));
end

function [data J] = curve_DFDU(opts, data, u) %#ok<INUSL>
x = u(data.x_idx);
p = u(data.p_idx);
J = [ data.fx(x,p) data.fp(x,p) ];
% [data J2] = fdm_ezDFDX('f(o,d,x)', opts, data, @curve, u);
end

function [data_ptr y] = test_HB(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J  = jacobian(data, u);
la = eig(J);
la = la(data.la_idx1)+la(data.la_idx2);
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = real(prod(la));
end

function [ msg data ] = evhan_HB( opts, command, data )
% data = { u0 u1 e0 e1 scale h evidx pars pidx [check: x t] } + fields added here
% monitor functions: [opts p ] = opts.efunc.monitor_F(opts, data.x);
% event functions:   [opts ev] = opts.efunc.events_F (opts,      p);
% use ev(data.evidx)
switch command
  
  case 'init'
    if isfield(data, 'finish')
      msg.action = 'finish';
    else
      fdata_ptr = coco_get_func_data(opts, 'test_HB', 'data');
      fdata     = fdata_ptr.data;
      J1  = jacobian(fdata, data.u0);
      la1 = eig(J1);
      J2  = jacobian(fdata, data.u1);
      la2 = eig(J2);
      if sum(sign(real(la1))) == sum(sign(real(la2)))
        msg.point_type = 'NSad';
      else
        msg.point_type = 'HB';
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
J  = jacobian(data, u);
la = eig(J);
sc = abs(la);
la = (2*la)./(max(1,sc)+sc);
y  = prod(la);
end

function [data_ptr y] = test_FP_tan(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J = jacobian(data, u);
b = par_deriv (data, u);
A = [J b; data.t'];
t = A\data.rhs;
y = t(end);
end

function [data_ptr y] = test_FP_ext(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J = jacobian(data, u);
M = [J data.b ; data.c data.d];
v = M\data.rhs;
y = v(end);
end

function [data_ptr y] = test_FP_ext_DFDU(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J    = jacobian(data, u);
M    = [J data.b ; data.c data.d];
v    = M\data.rhs;
w    = data.rhs'/M;
FXXv = dfvdxx(data, u, v(data.x_idx));
hx   = -w(data.x_idx)*FXXv;
FXPv = dfvdxp(data, u, v(data.x_idx));
hp   = -w(data.x_idx)*FXPv;
y    = [hx hp];
% [data_ptr J] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @test_FP_ext, u);
end

function [data_ptr y] = test_BP(opts, data_ptr, u) %#ok<INUSL>
data = data_ptr.data;
J = jacobian  (data, u);
b = par_deriv (data, u);
A = [J b; data.t'];
if issparse(A)
  [m n] = size(A); %#ok<NASGU>
  [L,U,P,Q,R] = lu(A); %#ok<ASGLU>
  DR  = full(diag(R));
  SR  = prod(sign(DR));
  DU  = full(diag(U));
  SU  = prod(sign(DU));
  DPQ = det(P)*det(Q);
  sru = sort(sort(abs(DR)).*sort(abs(DU),'descend'));
  
  % det(A) = DPQ*SR*SU*prod(sru)
  % we rescale and multiply only a few of the smallest factors of prod(sru)
  N   = min(10, m);
  la  = sru(1:N);
  la  = sqrt(la.*flipud(la));
  % sc  = nthroot(N,N/mean(sc))*(sc./( 1+sc ));
  % sc  = max(sru(1:N), ones(N,1))+sru(1:N);
  % sc  = 1+sru(1:N);
  % sc  = 2*( sru(1:N)./sc );
  sc = abs(la);
  la = (2*la)./(max(1,sc)+sc);
  y = DPQ*SR*SU*prod(la);
else
  y = det(A);
end
data.J = A;
data_ptr.data = data;
end

function J = jacobian(data, u)
if isempty(data.fx)
  J = fdm_ezDFDX('f(x,p)', data.f, u(data.x_idx), u(data.p_idx));
else
  J = data.fx(u(data.x_idx), u(data.p_idx));
end
end

function J = par_deriv(data, u)
if isempty(data.fp)
  J = fdm_ezDFDP('f(x,p)', data.f, u(data.x_idx), u(data.p_idx), data.acp_idx);
else
  J = data.fp(u(data.x_idx), u(data.p_idx));
  J = J(:,data.acp_idx);
end
end

function data = update_borders(data, J)
M0     = [J data.b ; data.c data.d];
w      = data.rhs'/M0;
data.b = w(data.x_idx)';
data.b = data.b/norm(data.b);
M0     = [J data.b ; data.c data.d];
v      = M0\data.rhs;
data.c = v(data.x_idx)';
data.c = data.c/norm(data.c);
data.d = 0;

% M0     = [J data.b ; data.c data.d];
% v      = M0\data.rhs;
% w      = data.rhs'/M0;
% data.b = w(data.x_idx)';
% data.b = data.b/norm(data.b);
% data.c = v(data.x_idx)';
% data.c = data.c/norm(data.c);
% data.d = 0;

% data.b = data.c/J;
% data.b = data.b'/norm(data.b);
% data.c = J\data.b;
% data.c = data.c'/norm(data.c);
% data.d = 0;

% b      = data.b;
% data.b = data.c/J;
% data.b = data.b'/norm(data.b);
% data.c = J\b;
% data.c = data.c'/norm(data.c);
% data.d = 0;

% M0     = [J data.b ; data.c data.d];
% w      = data.rhs'/M0;
% det1   = w(end);
% data.b = w(data.x_idx)';
% data.b = data.b/norm(data.b);
% M0     = [J data.b ; data.c data.d];
% v      = M0\data.rhs;
% data.c = v(data.x_idx)';
% data.c = data.c/norm(data.c);
% M0     = [J data.b ; data.c data.d];
% v      = M0\data.rhs;
% det3   = v(end);
% scale  = sqrt(det3/det1);
% data.b = scale*data.b;
% data.c = scale*data.c;
% data.d = 0;

end

function data_ptr = curve_update(opts, data_ptr, cmd, cseg, varargin)
data = data_ptr.data;
switch cmd
  case 'update'
    chart = cseg.base_chart;
    u = chart.x;
    t = chart.t;
    if data.update_borders
      % update bordering vectors for minimally extended systems
      J      = jacobian(data, u);
      data   = update_borders(data, J);
      M      = [J data.b ; data.c data.d];
      data.M = M;
    end

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
    res = { 'x' 'p' '||x||' 'evals' 'det(J)' }; % 'det(M)' };
  case 'data'
    data = data_ptr.data;
    x    = sol.x(data.x_idx);
    p    = sol.x(data.p_idx);
    J    = jacobian(data, sol.x);
    if issparse(J)
      res  = { x, p, norm(x), [], det(J) }; % det(data.M) };
    else
      res  = { x, p, norm(x), eig(J), det(J) }; % det(data.M) };
    end
end
end

function [data_ptr res] = curve_save(opts, data_ptr, sol, varargin) %#ok<INUSL>

data = data_ptr.data;

switch sol.pt_type
  case {'HB' 'NSad'}
    data.J = jacobian(data, sol.x);
  case 'BP'
    J      = jacobian (data, sol.x);
    b      = par_deriv(data, sol.x);
    A      = [J b; data.t'];
    data.J = A;
end

res = data;

end

function data_ptr = curve_print(opts, data_ptr, cmd, chart, u) %#ok<INUSL>
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
data.t_idx    = [ data.x_idx data.p_idx(acp_idx(1)) ];

% the initialisations below are, in principle, not necessary,
% but they make some test functions smoother at the initial point

% initialise bordering vectors for minimally extended systems
u      = data.u0;
J      = jacobian(data, u);
data   = update_borders(data, J);

% compute approximate first tangent
if isempty(data.tx) || isempty(data.tp)
  b      = par_deriv (data, u);
  data.t = [-J\b; 1];
else
  data.t = [ data.tx ; data.tp(data.acp_idx) ];
end
data.t = data.t/norm(data.t);

data_ptr.data = data;
end
