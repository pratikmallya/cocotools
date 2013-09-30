function opts = spc_ipo2po(opts, prefix, varargin)

% varargin = { f x0 p0 pnames T0 NSegs ... }
s     = coco_stream(varargin{:});
f     = s.get;
x0    = s.get;
pnms  = s.get('cell');
p0    = s.get;
T0    = s.get;

%% get toolbox settings
[opts spc] = spc_get_settings(opts, prefix);

%% construct toolbox data
data.f  = f;
data.Xi = spc.ContSym.Xi;
data.o  = ones(numel(x0),1);
p0      = [spc.ContSym.om0 ; p0(:)];
pnms    = [ coco_get_id(prefix, 'spc', 'om0') pnms ];

%% compute initial solution and construct segment objects
[t z] = ode45(@(t,x,p) uode_f(data, t, x, p), [0 T0], x0(:), [], p0);
segid = coco_get_id(prefix, 'spc', 'seg');
opts  = coll_isol2seg(opts, segid, @(x,p) uode_f(data, [], x, p), t, z, pnms, p0);

%% set up and initialise boundary conditions
spc.segid        = segid;
[opts coll xidx] = spc_add_BC(opts, prefix, spc);

%% add codim-1 test functions
% begin Poincare map for debugging
func  = @(x,p) uode_f(data, [], x, p);
x_dim = numel(data.o);
x_idx = 1:x_dim;
M_dim = x_dim*x_dim;
M_idx = x_idx(end)+(1:M_dim);

  function y=var_ode(t,x,p) %#ok<INUSL>
    J = fdm_ezDFDX('f(x,p)', func, x(x_idx), p);
    M = reshape(x(M_idx), [x_dim x_dim]);
    M = J*M;
    y = [ func(x(x_idx),p) ; M(:) ];
  end

  function [x1 M1] = var_map(x0, M0, p, T)
    x = [x0(:) ; M0(:)];
    [t z] = ode45(@var_ode, [0 T], x, [], p);
    x1 = z(end,x_idx)';
    M1 = reshape(z(end,M_idx), [x_dim x_dim]);
  end

% [x1 M1] = var_map(x0, eye(3,3), p0, T0);
% end Poincare map for debugging

% opts = spc_add_TF(opts, prefix, spc, xidx, coll, 1, @var_map);

end

function y = uode_f(data,t,x,p)
  y = data.f(t,x,p(2:end,:)) - p(data.o,:).*(data.Xi*x);
end
