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

J0   = sparse(rows, cols, vals);
deye = speye(dim);
B1   = [deye sparse(dim, fdata.xbp_idx(end)-2*dim) deye];
rhs  = [3*deye; sparse(fdata.xbp_idx(end)-dim, dim)];
B2   = (0.5/NTST)*fdata.W'*fdata.wts2*fdata.W;
M0   = data.M{data.nseg};
M    = [B1+M0'*B2; J0]\rhs;
while norm(full(M-M0))>fdata.coll.TOL
  M0 = M;
  J  = [B1+M0'*B2; J0];
  M  = J\rhs;
end
data.M{data.nseg} = M;

y = [];

end %!end_var_seg