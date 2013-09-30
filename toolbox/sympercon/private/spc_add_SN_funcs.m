function opts = pocont_add_SN_funcs(opts, prefix, pocont, xidx, coll)

%% compute initial eigenvector
fid          = coco_get_id(prefix, 'coll');
x0           = coco_get_func_data(opts, fid, 'x0');
coll_func    = sprintf('%s_ode_F', pocont.collocation);
coll_func    = str2func(coll_func);
f0           = coll_func(coll, 1, x0(coll.x0idx), x0(coll.p_idx));
M0           = reshape(x0(coll.m0idx), coll.mshape([1 3]));
M1           = reshape(x0(coll.m1idx), coll.mshape([1 3]));
M            = [ M1-M0 f0 ; f0'*M0 0];
[V D]        = eig(M);
[lpev lpidx] = min(abs(diag(D))); %#ok<ASGLU>
V            = V(:,lpidx);
x0           = [ V/norm(V(1:end-1)); 1 ];

%% create SN function data
data.m0idx     =                      1:numel(coll.m0idx);
data.m1idx     = data.m0idx(end)   + (1:numel(coll.m1idx));
data.evecidx   = data.m1idx(end)   + (1:coll.dim);
data.sidx      = data.evecidx(end) + 1;
data.evalidx   = data.sidx(end)    + 1;
data.mshape    = coll.mshape([1 3]);
data.f0        = f0;
data.x0idx     = xidx(coll.x0idx);
data.p_idx     = xidx(coll.p_idx);
data.coll_fid  = fid;
data.coll_func = coll_func;
data_ptr       = coco_ptr(data);

%% add eigenvalue equations
fid         = coco_get_id(prefix, 'SN_evcnd');
[opts xidx] = coco_add_func(opts, fid, @pocont_SN_F, @pocont_SN_DFDX, ...
  data_ptr, 'zero', 'xidx', xidx([coll.m0idx ; coll.m1idx]), 'x0', x0);

%% add call back function to update event
fid  = coco_get_id(prefix, 'SN_update');
data_ptr.data.fid = fid;
opts = coco_add_callback(opts, fid, @pocont_SN_update, ...
  data_ptr, 'FSM_update');

%% add saddle-node test function for parameter exchange
fid  = coco_get_id(prefix, 'TF_SN');
opts = coco_add_func(opts, fid, @func_SN, @func_DSNDX, ...
  data_ptr, 'internal', fid, 'xidx', xidx(data.evalidx));
opts = coco_set_parival(opts, fid, 0);

end

%%
function [data_ptr f] = pocont_SN_F(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;

M0 = reshape(xp(data.m0idx), data.mshape);
M1 = reshape(xp(data.m1idx), data.mshape);
xx = xp(data.evecidx);
mu = xp(data.evalidx);
s  = xp(data.sidx);
f0 = data.f0;

f = [ (M1-mu*M0)*xx + s*f0 ; f0'*M0*xx ; xx'*xx-1 ];
end

%%
function [data_ptr J] = pocont_SN_DFDX(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;

M0    = reshape(xp(data.m0idx), data.mshape);
M0idx = reshape(data.m0idx,     data.mshape);
M1    = reshape(xp(data.m1idx), data.mshape);
M1idx = reshape(data.m1idx,     data.mshape);

xx    = repmat(xp(data.evecidx)', data.mshape(1), 1);
xxidx = repmat(data.evecidx,      data.mshape(1), 1);
sidx  = repmat(data.sidx,         data.mshape(1), 1);

mu    = xp(data.evalidx);
muidx = data.evalidx(ones(data.mshape(1),1));

rowidx = repmat((1:data.mshape(1))', 1, data.mshape(2));

% derivative of (M1-mu*M0)*xx + s*f0
rows = [ rowidx  rowidx rowidx    rowidx(:,1)  rowidx(:,1) ];
cols = [ M1idx   M0idx  xxidx     muidx        sidx        ];
vals = [ xx     -mu*xx  M1-mu*M0 -M0*xx(1,:)'  data.f0     ];

r    = numel(data.evecidx);

% derivative of f0'*M0*xx
f0xp = data.f0*xp(data.evecidx)';
f0M0 = data.f0'*M0;

rows = [ rows(:) ; (r+1)*ones(r*r,1) ; (r+1)*ones(r,1) ];
cols = [ cols(:) ; M0idx(:)          ; data.evecidx(:) ];
vals = [ vals(:) ; f0xp(:)           ; f0M0(:)         ];

% derivative of xx'*xx-1
rows = [ rows(:) ; (r+2)*ones(r,1)      ];
cols = [ cols(:) ; data.evecidx(:)      ];
vals = [ vals(:) ; 2.0*xp(data.evecidx) ];

J = sparse(rows, cols, vals, r+2, numel(xp));
end

%%
function [data_ptr varargout] = pocont_SN_update(opts, data_ptr, cmd, varargin)

data  = data_ptr.data;

switch cmd
  case 'update'
    x     = varargin{1};
    x0    = x(data.x0idx);
    p     = x(data.p_idx,1);
    coll  = coco_get_func_data(opts, data.coll_fid, 'data');
    
    data.f0 = data.coll_func(coll, 1, x0, p);
    
  case 'get_state'
    varargout{1} = data;
    
  case 'restore_state'
    data = coco_slot_data(data_ptr.data.fid, varargin{1});
    
  otherwise
end

data_ptr.data = data;

end

%%
function [data_ptr g] = func_SN(opts, data_ptr, xp) %#ok<INUSL>
g = xp - 1;
end

%%
function [data_ptr J] = func_DSNDX(opts, data_ptr, xp) %#ok<INUSD,INUSL>
J = speye(1);
end
