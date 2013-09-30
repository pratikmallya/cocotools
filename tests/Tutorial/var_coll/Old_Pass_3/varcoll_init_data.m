function data = varcoll_init_data(data, u0)

N = data.coll.NTST;
m = data.coll.NCOL;
n = data.dim;
q = data.pdim;

data.ubp_idx   = n*N*(m+1)+1+q+(1:n^2*N*(m+1));
data.u_shp     = [n*N*(m+1) n];

rows = reshape(1:n^2*N*m, [n^2 N*m]);
data.dxdxrows1 = repmat(rows, [n 1]);
data.dxdxcols1 = repmat(1:n*N*m, [n^2 1]);

cols = repmat(1:n*N*m, [n 1]);
data.dxdxcols2 = repmat(cols(:), [n*N*(m+1) 1]);
rows = reshape(1:n^2*N^2*m*(m+1), [n n*N^2*m*(m+1)]);
data.dxdxrows2 = repmat(rows, [n 1]);

cols = repmat(1:n*N*(m+1), [n*N*m 1]);
data.dxdxcols3 = repmat(cols(:), [n 1]);
rows = reshape(1:n^2*N*m, [n*N*m n]);
data.dxdxrows3 = repmat(rows, [n*N*(m+1) 1]);

cols = repmat(1:n*N*m, [n 1]);
data.dxdpcols1 = repmat(cols(:), [q 1]);
rows = reshape(1:n*N*m*q, [n N*m*q]);
data.dxdprows1 = repmat(rows, [n 1]);

cols = repmat(1:q, [n*N*m 1]);
data.dxdpcols2 = repmat(cols(:), [n 1]);
rows = reshape(1:n^2*N*m, [n*N*m n]);
data.dxdprows2 = repmat(rows, [q 1]);

deye    = speye(n);
data.Id = deye;
data.B1 = sparse([deye sparse(n, n*N*(m+1)-2*n) deye]);
data.B2 = (0.5/N)*data.W'*data.wts2*data.W;
data.M0 = var_init(data, u0);
data.B  = data.B1 + data.M0'*data.B2;

data.jac = ...
  [sparse(n^2*N, n*N*(m+1)+1+q) ...
  [kron(deye, data.Q); kron(deye, data.B)]];

end

function M0 = var_init(data, u)

x = u(data.xbp_idx);
T = u(data.T_idx);
p = u(data.p_idx);

NTST = data.coll.NTST;
NCOL = data.coll.NCOL;
dim  = data.dim;
deye = data.Id;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);

dfode = data.dfdxhan(xx, pp, data.mode);
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);
rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];

M0 = repmat(deye, [NTST*(NCOL+1) 1]);
for itr=1:data.varcoll.NBIT
  beta = itr/data.varcoll.NBIT;
  J0 = sparse(rows, cols, [beta*vals(:); data.Qvals(:)]);
  J  = [data.B1+M0'*data.B2; J0];
  M  = J\[3*deye; sparse(data.xbp_idx(end)-dim, dim)];
  while norm(full(M-M0))>data.coll.TOL
    M0 = M;
    J  = [data.B1+M0'*data.B2; J0];
    M  = J\[3*deye; sparse(data.xbp_idx(end)-dim, dim)];
  end
  M0 = M;
end

end %!end_var_init