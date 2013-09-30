function [vardata x0] = var_system(data, x0)

p0  = x0(data.p_idx);
x0  = x0(data.x_idx);
xbp = x0(data.xbpidx);
T   = x0(data.Tidx);

dim  = data.dim;
NTST = data.NTST;
NCOL = data.NCOL;

xx  = reshape(data.W * xbp, [dim NTST*NCOL]);
pp  = repmat(p0, [1 NTST*NCOL]);

if isempty(data.dfdxhan)
    dfode = coll_num_DFDX(data.fhan, xx, pp, data.mode);
else
    dfode = data.dfdxhan(xx, pp, data.mode);
end
dfode = reshape(dfode, [dim*dim*NTST*NCOL 1]);
dfode = sparse(data.dxrows, data.dxcols, dfode);
dfode = (0.5 * T / NTST) * dfode * data.W;

V1 = [dfode ; sparse(NTST*dim,NTST*(NCOL+1)*dim)];
vardata.var1 = kron(eye(dim),V1);

vardata.var2upper = [-data.Wp ; data.Q];

Omega = spdiags(data.wt(:),0,dim*NTST*NCOL,dim*NTST*NCOL);
vardata.B1 = sparse([eye(dim) zeros(dim,NTST*(NCOL+1)*dim-2*dim) eye(dim)]);
vardata.B2 = (0.5 / NTST) * data.W' * Omega * data.W;
xbp0 = repmat(eye(dim),[NTST*(NCOL+1), 1]);
B  = vardata.B1 + xbp0' * vardata.B2;
V2 = [vardata.var2upper ; B];
vardata.var2 = kron(eye(dim),V2);
vardata.var2x0reshape = [data.NTST*(data.NCOL+1)*data.dim, data.dim];

V3 = -3*sparse([zeros(NTST*NCOL*dim+NTST*dim-dim,dim);eye(dim,dim)]);
vardata.var3 = reshape(V3, [numel(V3), 1]);

vardata.x_idx = 1:dim*NTST*(NCOL+1)*dim;
vardata.p_idx = dim*NTST*(NCOL+1)*dim+1;
vardata.dim   = dim;

x0 = repmat(eye(dim,dim), [NTST*(NCOL+1), 1]);
x0 = reshape(x0, [dim*NTST*(NCOL+1)*dim, 1]);

end