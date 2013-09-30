function opts = pocont_add_PD_funcs(opts, prefix, pocont, xidx, coll)

%% compute initial eigenvector
fid                  = coco_get_id(prefix, 'coll');
x0                   = coco_get_func_data(opts, fid, 'x0');
tfdata.tf_weight     = pocont.tf_weight;
tfdata.mshape        = [coll.x0shape(1) coll.x0shape(1) coll.m0shape(2)];
tfdata.m0idx         = coll.m0idx;
tfdata.m1idx         = coll.m1idx;
[tfdata evecs evals] = pocont_multipliers(opts, tfdata, x0); %#ok<ASGLU>
evals                = diag(evals);
[pdev pdidx]         = min(abs(evals+1)); %#ok<ASGLU>
x0                   = [evecs(:,pdidx) ; -1];

%% create PD function data
data.m0idx   =                      1:numel(coll.m0idx);
data.m1idx   = data.m0idx(end)   + (1:numel(coll.m1idx));
data.evecidx = data.m1idx(end)   + (1:coll.dim);
data.evalidx = data.evecidx(end) + 1;
data.mshape  = coll.mshape([1 3]);

%% add eigenvalue equations
fid         = coco_get_id(prefix, 'PD_evcnd');
[opts xidx] = coco_add_func(opts, fid, @pocont_PD_F, @pocont_PD_DFDX, ...
  data, 'zero', 'xidx', xidx([coll.m0idx ; coll.m1idx]), 'x0', x0);

%% add period-doubling test function for parameter exchange
fid  = coco_get_id(prefix, 'TF_PD');
opts = coco_add_func(opts, fid, @func_PD, @func_DPDDX, ...
  data, 'internal', fid, 'xidx', xidx(data.evalidx));
opts = coco_set_parival(opts, fid, 0);

end

%%
function [data f] = pocont_PD_F(opts, data, xp) %#ok<INUSL>

M0 = reshape(xp(data.m0idx), data.mshape);
M1 = reshape(xp(data.m1idx), data.mshape);
xx = xp(data.evecidx);
mu = xp(data.evalidx);

f = [ (M1-mu*M0)*xx ; xx'*xx-1 ];
end

%%
function [data J] = pocont_PD_DFDX(opts, data, xp) %#ok<INUSL>

M0    = reshape(xp(data.m0idx), data.mshape);
M0idx = reshape(data.m0idx,     data.mshape);
M1    = reshape(xp(data.m1idx), data.mshape);
M1idx = reshape(data.m1idx,     data.mshape);

xx    = repmat(xp(data.evecidx)', data.mshape(1), 1);
xxidx = repmat(data.evecidx,      data.mshape(1), 1);

mu    = xp(data.evalidx);

rowidx = repmat((1:data.mshape(1))', 1, data.mshape(2));

% derivative of (M1-mu*M0)*xx
rows = [ rowidx  rowidx rowidx    rowidx(:,1)                          ];
cols = [ M1idx   M0idx  xxidx     data.evalidx(ones(data.mshape(1),1)) ];
vals = [ xx     -mu*xx  M1-mu*M0 -M0*xx(1,:)'                          ];

% derivative of xx'*xx-1
r    = numel(data.evecidx);
rows = [ rows(:) ; (r+1)*ones(r,1)      ];
cols = [ cols(:) ; data.evecidx(:)      ];
vals = [ vals(:) ; 2.0*xp(data.evecidx) ];

J = sparse(rows, cols, vals, r+1, numel(xp));
end

%%
function [data g] = func_PD(opts, data, xp) %#ok<INUSL>
g = xp + 1;
end

%%
function [data J] = func_DPDDX(opts, data, xp) %#ok<INUSD,INUSL>
J = speye(1);
end
