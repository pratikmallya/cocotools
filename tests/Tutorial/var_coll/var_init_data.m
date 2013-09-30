function vardata = var_init_data(data, u0)

xbp = u0(data.xbp_idx);
T   = u0(data.T_idx);
p0  = u0(data.p_idx);

dim  = data.dim;
NTST = data.coll.NTST;
NCOL = data.coll.NCOL;

xx  = reshape(data.W * xbp, [dim NTST*NCOL]);
pp  = repmat(p0, [1 NTST*NCOL]);

if isempty(data.dfdxhan)
    dfode = coll_num_DFDX(data.fhan, xx, pp, data.model);
else
    dfode = data.dfdxhan(xx, pp, data.model);
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
vardata.var2x0reshape = [NTST*(NCOL+1)*dim, dim];

V3 = -3*sparse([zeros(NTST*NCOL*dim+NTST*dim-dim,dim);eye(dim,dim)]);
vardata.var3 = reshape(V3, [numel(V3), 1]);

vardata.x_idx = 1:dim*NTST*(NCOL+1)*dim;
vardata.p_idx = dim*NTST*(NCOL+1)*dim+1;
vardata.dim   = dim;

vardata.init  = repmat(eye(dim,dim), [NTST*(NCOL+1), 1]);
end