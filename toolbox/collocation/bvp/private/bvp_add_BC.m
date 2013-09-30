function opts = bvp_add_BC(opts, prefix, bcnd)
%Create and initialise boundary conditions.
%
%   OPTS = MPBVP_CREATEBOUNDARYCONDITIONS(OPTS, X0, P0)
%   initialises the class 'bcond' and calls the functions OPTS.BCOND.INIT
%   and OPTS.BCOND.UPDATE.
%

fid         = coco_get_id(prefix, 'coll');
[coll xidx] = coco_get_func_data(opts, fid, 'data', 'xidx');

data.F        = bcnd.fhan;
data.DFDX     = bcnd.dfdxhan;
data.DFDP     = bcnd.dfdphan;
data.x0_idx   = 1:numel(coll.x0idx);
data.x0_shape = coll.x0shape;
data.x1_idx   = data.x0_idx(end) + (1:numel(coll.x1idx));
data.x1_shape = coll.x1shape;
data.T_idx    = data.x1_idx(end) + (1:numel(coll.tintidx));
data.p_idx    = data.T_idx(end)  + (1:numel(coll.p_idx));
data.J_perm   = [data.T_idx data.x0_idx data.x1_idx data.p_idx];

bc_xidx = xidx([coll.x0idx ; coll.x1idx ; coll.tintidx ; coll.p_idx]);
fid     = coco_get_id(prefix, 'bcnd');
opts    = coco_add_func(opts, fid, @bcnd_F, @bcnd_DFDX, data, ...
  'zero', 'xidx', bc_xidx);

%% add external parameters if top-level toolbox
if isempty(prefix)
  opts = coco_add_parameters(opts, prefix, ...
    xidx(coll.p_idx), 1:numel(coll.p_idx));
end

%% add call back function
fid  = coco_get_id(prefix, 'bcnd');
opts = coco_add_slot(opts, fid, @coco_save_data,  bcnd, 'save_full');

end

%%
function [data f] = bcnd_F(opts, data, xp) %#ok<INUSL>

T  = xp(data.T_idx,1);
x0 = reshape(xp(data.x0_idx,1), data.x0_shape);
x1 = reshape(xp(data.x1_idx,1), data.x0_shape);
p  = xp(data.p_idx,1);

f = data.F(T, x0, x1, p);
end

%%
function [data J] = bcnd_DFDX(opts, data, xp) %#ok<INUSL>

T  = xp(data.T_idx,1);
x0 = xp(data.x0_idx,1);
x1 = xp(data.x1_idx,1);
p  = xp(data.p_idx,1);

[JT Jx0 Jx1 Jp]  = data.DFDX(T, x0, x1, p);
J(:,data.J_perm) = [ JT Jx0 Jx1 Jp];
end
