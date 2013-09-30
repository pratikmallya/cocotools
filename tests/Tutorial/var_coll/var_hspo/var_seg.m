%!var_seg
function [data y] = var_seg(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid{data.nseg}, 'data');
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
it   = 0;
while norm(M(:)-M0(:))>fdata.coll.TOL
  % M0 = (2/3)*M0 + (1/3)*M; % stabalized formula for Banach iteration (see my notes)
  M0 = M; % simple Banach iteration
  J  = [B1+M0'*B2; J0];
  M  = J\rhs;
  it = it+1;
end

data.M{data.nseg} = M;
data.nseg = mod(data.nseg, data.nsegs)+1;

y = [];

dim  = size(M,2);
M0   = full(M(1:dim,:));
M1   = full(M(end-dim+1:end,:));
[M0 M1];
test = eig(M1,M0);
fprintf('%s: #It = %4d, multipliers: % .2e+% .2ei % .2e+% .2ei\n', mfilename, it, ...
  real(test(1)), imag(test(1)), real(test(2)), imag(test(2)));

end %!end_var_seg