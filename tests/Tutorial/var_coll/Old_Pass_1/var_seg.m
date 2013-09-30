%!var_seg
function [data y] = var_seg(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid, 'data', 'uidx');
x     = u(fdata.xbp_idx);
T     = u(fdata.T_idx);
p     = u(fdata.p_idx);
NTST  = fdata.coll.NTST;
dim   = fdata.dim;

xx = reshape(fdata.W*x, fdata.x_shp);
pp = repmat(p, fdata.p_rep);
if isempty(fdata.dfdxhan)
  dfode = coco_ezDFDX('f(x,p)v', fdata.fhan, xx, pp, fdata.mode);
else
  dfode = fdata.dfdxhan(xx, pp, fdata.mode);
end
dfode = sparse(fdata.dxrows, fdata.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*fdata.W-fdata.Wp;
[rows cols vals] = find(dfode);
rows = [rows(:); fdata.off+fdata.Qrows(:)];
cols = [cols(:); fdata.Qcols(:)];
vals = [vals(:); fdata.Qvals(:)];

J   = sparse(rows, cols, vals);
dey = speye(dim);
%     row = [.5*dey, sparse(dim, fdata.xbp_idx(end)-2*dim), .5*dey];
row = [sparse(dim, fdata.xbp_idx(end)-dim), dey];
rhs = [dey; sparse(fdata.xbp_idx(end)-dim, dim)];
data.J = [row; J];
data.M{data.nseg} = data.J\rhs;

y = [];

end %!end_var_seg
%     row = [dey, sparse(dim, fdata.xbp_idx(end)-dim)];
%     row = [sparse(dim, fdata.xbp_idx(end)-dim), dey];