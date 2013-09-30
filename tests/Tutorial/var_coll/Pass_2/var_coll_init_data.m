function data = var_coll_init_data(prob, data)

fdata = coco_get_func_data(prob, data.coll_id, 'data');

NTST   = fdata.coll.NTST;
NCOL   = fdata.coll.NCOL;
dim    = fdata.dim;
pdim   = fdata.pdim;
xbpnum = (NCOL+1)*NTST;
xbpdim = dim*(NCOL+1)*NTST;
ubpdim = dim^2*(NCOL+1)*NTST;
xcnnum = NCOL*NTST;
xcndim = dim*NCOL*NTST;
ucndim = dim^2*NCOL*NTST;

data.dim     = dim;
data.M1_idx  = xbpdim-dim+(1:dim)';
data.ubp_idx = xbpdim+1+pdim+(1:ubpdim)';
data.u_shp   = [xbpdim dim];
data.R       = [speye(dim) sparse(dim, xbpdim-dim)];
data.Id      = eye(dim);
data.jac     = [sparse(dim^2*NTST, xbpdim+1+pdim) ...
               [kron(eye(dim), fdata.Q); kron(eye(dim), data.R)]];

rows = reshape(1:ucndim, [dim^2 xcnnum]);
data.dxdxrows1 = repmat(rows, [dim 1]);
data.dxdxcols1 = repmat(1:xcndim, [dim^2 1]);

rows = reshape(1:xbpdim*xcndim, [dim xbpnum*xcndim]);
data.dxdxrows2 = repmat(rows, [dim 1]);
data.dxdxcols2 = repmat(1:xcndim, [dim xbpdim]);

rows = reshape(1:ucndim, [xcndim dim]);
data.dxdxrows3 = repmat(rows, [xbpdim 1]);
data.dxdxcols3 = repmat(1:xbpdim, [xcndim dim]);

rows = reshape(1:xcndim, [dim xcnnum]);
data.dxdprows  = repmat(rows, [dim*pdim 1]);
cols = permute(reshape(1:xcndim*pdim, [dim xcnnum pdim]), [1 3 2]);
data.dxdpcols  = repmat(cols(:)', [dim 1]);
data.dxdp_shp  = [ucndim pdim];

end