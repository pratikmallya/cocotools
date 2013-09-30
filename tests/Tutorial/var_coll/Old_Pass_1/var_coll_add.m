%!var_coll_add
function prob = var_coll_add(prob, segoid, mode)

data = var_coll_init_data(prob, segoid, mode);
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
tbid = coco_get_id(segoid, 'var');
pid  = coco_get_id(tbid, {'cond' '||M||'});
prob = coco_add_func(prob, tbid, @var_seg, data, ...
  'regular', pid, 'uidx', uidx);

end %!end_var_coll_add
%!var_coll_init_data
function data = var_coll_init_data(prob, segoid, mode)

data.tbid = coco_get_id(segoid, 'coll');
data.mode = mode;
fdata     = coco_get_func_data(prob, data.tbid, 'data');
data      = coco_merge(data, fdata, {'xbp_idx' 'T_idx' 'p_idx' 'dim' ...
  'W' 'Wp' 'x_shp' 'p_rep' 'fhan' 'dfdxhan' 'dxrows' 'dxcols' ...
  'off' 'Qrows' 'Qcols' 'Qvals'});
data.NTST = fdata.coll.NTST;

dim          = data.dim;
data.M0_idx  = data.xbp_idx(1:dim);
data.M1_idx  = data.xbp_idx(end-dim+(1:dim));

switch data.mode
  case 'left'
    ze = sparse(dim, data.xbp_idx(end)-dim);
    data.row = [speye(dim) ze];
  case 'right'
    ze = sparse(dim, data.xbp_idx(end)-dim);
    data.row = [ze speye(dim)];
  case 'average'
    ze = sparse(dim, fdata.xbp_idx(end)-2*dim);
    data.row = 0.5*[speye(dim) ze speye(dim)];
  otherwise
    error('%s: unknown mode', mfilename);
end
data.rhs = [eye(dim); zeros(fdata.xbp_idx(end)-dim, dim)];

end %!end_var_coll_init_data
%!var_seg
function [data y] = var_seg(prob, data, u)

x    = u(data.xbp_idx);
T    = u(data.T_idx);
p    = u(data.p_idx);
NTST = data.NTST;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);
if isempty(data.dfdxhan)
  dfode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dfode = data.dfdxhan(xx, pp);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);

rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];
vals = [vals(:); data.Qvals(:)];
J    = sparse(rows, cols, vals);

J      = [data.row; J];
data.M = J\data.rhs;

y = [ condest(J); max(abs(data.M(:))) ];

end %!end_var_seg