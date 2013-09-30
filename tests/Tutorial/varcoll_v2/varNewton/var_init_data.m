function vardata = var_init_data(data, u0)

xbp  = u0(data.xbp_idx);
T    = u0(data.T_idx);
p0   = u0(data.p_idx);

dim  = data.dim;
NTST = data.coll.NTST;
NCOL = data.coll.NCOL;

xx   = reshape(data.W * xbp, [dim NTST*NCOL]);
pp   = repmat(p0, [1 NTST*NCOL]);

vardata       = coco_func_data();
vardata.dim   = dim;
vardata.x_idx = 1:dim*NTST*(NCOL+1)*dim;
vardata.p_idx = dim*NTST*(NCOL+1)*dim+1;
vardata.M0    = repmat(eye(dim,dim), [NTST*(NCOL+1), 1]);

if isempty(data.dfdxhan)
  dfode = coll_num_DFDX(data.fhan, xx, pp, data.model);
else
  dfode = data.dfdxhan(xx, pp, data.model);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W;

deye = speye(dim);
vardata.fx = kron(deye, dfode);
vardata.Wp = kron(deye, data.Wp);
vardata.Q  = kron(deye, data.Q);
vardata.z1 = sparse(size(vardata.Q,1),1);

vardata.B1 = [deye sparse(dim,NTST*(NCOL+1)*dim-2*dim) deye];
vardata.B2 = (0.5/NTST)*data.W'*data.wts2*data.W;
vardata.B  = kron(deye, vardata.B1+vardata.M0'*vardata.B2);
vardata.z2 = sparse(size(vardata.B,1),1);
vardata.I3 = reshape(3*deye, [dim*dim, 1]);

vardata.M_shape = [NTST*(NCOL+1)*dim, dim];

end