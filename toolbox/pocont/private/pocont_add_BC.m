function [opts coll xidx] = pocont_add_BC(opts, prefix, pocont)
%Initialise periodic boundary condition.

%% get data of collocation system
coll_fid       = coco_get_id(prefix, 'coll');
[coll xidx x0] = coco_get_func_data(opts, coll_fid, 'data', 'xidx', 'x0');
x0             = x0(coll.x_idx);

%% copy some fields from coll to data
data.W      = coll.W;
data.Wp     = coll.Wp;
data.ka     = coll.ka;
data.kaxidx = coll.kaxidx;
data.xshape = coll.xshape;
data.xidx   = xidx(coll.x_idx);

%% initialise periodic continuity condition
x0idx = reshape(coll.x0idx, coll.x0shape);
x1idx = reshape(coll.x1idx, coll.x1shape);
x1idx = x1idx(:,[end 1:end-1]);

[n segnum] = size(x0idx);

rows = [1:n*segnum 1:n*segnum];
cols = [x0idx(:) ; x1idx(:)];
vals = [ones(1,n*segnum) -ones(1,n*segnum)];
off  = n*segnum;

%% initialise time-of-flight conditions
%  we keep the ratios constant here
idx     = coll.tintidx;
T       = x0(idx);
[TT ii] = max(T);
T(ii)   = [];
idx(ii) = [];
ga      = -T./TT;
nrows   = length(T);
ii      = repmat(coll.tintidx(ii), [nrows 1]);

rows = [rows  off+[1:nrows 1:nrows]];
cols = [cols ; idx ; ii ];
vals = [vals ones(1,nrows) ga'];
off  = off + nrows;

%% create matrix encoding boundary condition
data.Phi = sparse(rows, cols, vals, off, coll.fullsize);

%% initialise phase condition
xx       = data.W  * x0;
xxp      = data.Wp * x0;
ka       = reshape(data.ka(data.kaxidx), [prod(data.xshape) 1]);
xxp      = ka .* xxp;
xxp      = xxp/norm(xxp);

data.x0  = xx;
data.x0p = xxp';
data_ptr = coco_ptr(data);

%% add periodic boundary conditions and update slot
switch pocont.phase_cond
  case 'internal'
    fid     = coco_get_id(prefix, 'bcnd');
    opts    = coco_add_func(opts, fid, @periodic_bc_F, @periodic_bc_DFDX, ...
      data_ptr, 'zero', 'xidx', data.xidx);
    fid  = coco_get_id(prefix, 'pc_update');
    data_ptr.data.fid = fid;
    opts = coco_add_slot(opts, fid, @periodic_bc_update, ...
      data_ptr, 'FSM_update');
    
  case 'external'
    fid     = coco_get_id(prefix, 'bcnd');
    opts    = coco_add_func(opts, fid, @periodic_bc_F2, @periodic_bc_DFDX2, ...
      data_ptr, 'zero', 'xidx', data.xidx);
    
  otherwise
    error('%s: illegal value for property ''phase_cond''', mfilename);
end

%% add period as internal parameter
fid     = coco_get_id(prefix, 'Period');
opts    = coco_add_func(opts, fid, @func_T, @func_DTDX, ...
  data_ptr, 'internal', fid, 'xidx', xidx(coll.tintidx));

end

%%
function [data_ptr fbc] = periodic_bc_F(opts, data_ptr, x) %#ok<INUSL>
%Evaluate periodic boundary and integral phase condition.

data = data_ptr.data;

% map base points to collocation points
xx = data.W * x;

fbc = [ ...
	% periodicity condition
	data.Phi * x; ...
	
	% integral phase condition
	data.x0p * (xx - data.x0) ...
];

end

%%
function [data_ptr Jbc] = periodic_bc_DFDX(opts, data_ptr, x) %#ok<INUSL,INUSD>
%Compute linearisation of periodic boundary condition.

data = data_ptr.data;

Jbc = [ ...
	data.Phi; ...
	data.x0p * data.W ...
];

end

function [data_ptr fbc] = periodic_bc_F2(opts, data_ptr, x) %#ok<INUSL>
%Evaluate periodic boundary and integral phase condition.

data = data_ptr.data;

fbc = data.Phi * x;

end

%%
function [data_ptr Jbc] = periodic_bc_DFDX2(opts, data_ptr, x) %#ok<INUSL,INUSD>
%Compute linearisation of periodic boundary condition.

data = data_ptr.data;

Jbc = data.Phi;

end

%%
function data_ptr = periodic_bc_update(opts, data_ptr, cmd, varargin) %#ok<INUSL>
%Update previous-point information for phase condition.

data = data_ptr.data;

switch cmd
  case 'update'
    chart = varargin{1}.base_chart;
    x   = chart.x;
    x   = x(data.xidx);
    x0  = data.W  * x;
    x0p = data.Wp * x;
    ka  = reshape(data.ka(data.kaxidx), [prod(data.xshape) 1]);
    x0p = ka .* x0p;
    x0p = x0p/norm(x0p);
    
    data.x0  = x0;
    data.x0p = x0p';
    
  otherwise
end

data_ptr.data = data;

end

%%
function [data T] = func_T(opts, data, x) %#ok<INUSL>
%Return period.

T = sum(x);

end

%%
function [data DT] = func_DTDX(opts, data, x) %#ok<INUSL>

DT   = ones(1,numel(x));

end
