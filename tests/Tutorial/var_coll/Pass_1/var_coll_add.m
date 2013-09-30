%!var_coll_add
function prob = var_coll_add(prob, segoid)

data = var_coll_init_data(prob, segoid);
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
tbid = coco_get_id(segoid, 'var');
prob = coco_add_func(prob, tbid, @var_coll_seg, data, ...
  'regular', {}, 'uidx', uidx);

end %!end_var_coll_add
%!var_coll_init_data
function data = var_coll_init_data(prob, segoid)

data.tbid   = coco_get_id(segoid, 'coll');
fdata       = coco_get_func_data(prob, data.tbid, 'data');

dim         = fdata.dim;
data.dim    = dim;
data.M1_idx = fdata.xbp_idx(end-dim+(1:dim));
data.row    = [eye(dim), zeros(dim, fdata.xbp_idx(end)-dim)];

end %!end_var_coll_init_data
%!var_coll_seg
function [data y] = var_coll_seg(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid, 'data');

x = u(fdata.xbp_idx);
T = u(fdata.T_idx);
p = u(fdata.p_idx);

xx = reshape(fdata.W*x, fdata.x_shp);
pp = repmat(p, fdata.p_rep);

if isempty(fdata.dfdxhan)
  dxode = coco_ezDFDX('f(x,p)v', fdata.fhan, xx, pp);
else
  dxode = fdata.dfdxhan(xx, pp);
end
dxode = sparse(fdata.dxrows, fdata.dxcols, dxode(:));
dxode = (0.5*T/fdata.coll.NTST)*dxode*fdata.W-fdata.Wp;

data.M = [data.row; dxode; fdata.Q]\data.row';

y = [];

end %!end_var_coll_seg