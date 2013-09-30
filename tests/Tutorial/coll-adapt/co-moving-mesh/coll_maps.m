function maps = coll_maps(int, NTST, pdim)

NCOL = int.NCOL;
dim  = int.dim;

maps.NTST = NTST;
maps.NCOL = NCOL;
maps.dim  = dim;
maps.pdim = pdim;

maps.wt = repmat(int.wt, [NTST 1]);

maps.x_idx  = 1:dim*(NCOL+1)*NTST + 1;
maps.p_idx  = maps.x_idx(end) + (1:pdim);
maps.ka_idx = maps.p_idx(end) + (1:NTST);
maps.la_idx = maps.ka_idx(end) + 1;

maps.xbpidx  = 1:dim*(NCOL+1)*NTST;
maps.Tidx    = dim*(NCOL+1)*NTST+1;
maps.Tpidx   = [ maps.Tidx maps.p_idx ];

maps.xtr    = [maps.x_idx maps.p_idx];
maps.xtr(dim+1:end-dim-pdim-1) = 0;
maps.xtrend = maps.xtr(end-dim-pdim:end);

dup_idx  = 1+((NCOL+1):(NCOL+1):((NCOL+1)*NTST-1));
tbp_uidx = 1:(NCOL+1)*NTST;
tbp_uidx(dup_idx) = [];
maps.tbp_uidx = tbp_uidx;

maps.fka_idx  = kron(1:NTST,ones(dim,NCOL));
maps.dxka_idx = reshape(kron(maps.fka_idx,ones(1, dim)), [dim  dim NCOL*NTST]);
maps.dpka_idx = reshape(kron(maps.fka_idx,ones(1,pdim)), [dim pdim NCOL*NTST]);

maps.x_shape  = [dim NTST*(NCOL+1)];
maps.xx_shape = [dim NTST*NCOL];
maps.pp_shape = [1 NTST*NCOL];

dxrows      = reshape(1:dim*NCOL*NTST, [dim NCOL*NTST]);
dxrows      = repmat(dxrows, [dim 1]);
maps.dxrows = reshape(dxrows, [dim*dim*NCOL*NTST 1]);

dxcols      = repmat(1:dim*NCOL*NTST, [dim 1]);
maps.dxcols = reshape(dxcols, [dim*dim*NCOL*NTST 1]);

maps.frows  = 1:dim*NTST*NCOL;
maps.fcols  = repmat(dim*(NCOL+1)*NTST+1, [dim*NTST*NCOL,1]);
maps.off    = dim*NTST*NCOL;

dprows      = reshape(1:dim*NCOL*NTST, [dim NCOL*NTST]);
dprows      = repmat(dprows, [pdim 1]);
maps.dprows = reshape(dprows, [dim*NCOL*NTST*pdim 1]);

dpcols      = repmat(maps.p_idx, [dim 1]);
dpcols      = repmat(dpcols, [1 NCOL*NTST]);
maps.dpcols = reshape(dpcols, [dim*NCOL*NTST*pdim 1]);

temp        = reshape(1:dim*(NCOL+1)*NTST, [dim*(NCOL+1) NTST]);
maps.x0idx  = temp(1:dim,1);
maps.x1idx  = temp(dim*NCOL+1:end,end);
ipidx       = reshape(temp(1:dim, 2:end),[1 dim*(NTST-1)]);
epidx       = reshape(temp(dim*NCOL+1:end, 1:end-1),[1 dim*(NTST-1)]);

maps.Qrows  = [1:dim*(NTST-1) 1:dim*(NTST-1)];
maps.Qcols  = [ipidx epidx];
maps.Qvals  = [ones(1,dim*(NTST-1)) -ones(1,dim*(NTST-1))];
maps.Q      = sparse(maps.Qrows, maps.Qcols, maps.Qvals, ...
  dim*(NTST-1), dim*(NCOL+1)*NTST);

rows        = reshape(1:dim*NCOL*NTST, [dim*NCOL NTST]);
rows        = repmat(rows, [dim*(NCOL+1) 1]);
rows        = reshape(rows, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
cols        = repmat(1:dim*(NCOL+1)*NTST, [dim*NCOL 1]);
cols        = reshape(cols, [dim*(NCOL+1)*dim*NCOL*NTST 1]);

W           = repmat(int.W, [1 NTST]);
W           = reshape(W, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
Wp          = repmat(int.Wp, [1 NTST]);
Wp          = reshape(Wp, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
maps.W      = sparse(rows, cols, W);
maps.Wp     = sparse(rows, cols, Wp);

rows        = reshape(1:dim*NTST, [dim NTST]);
rows        = repmat(rows, [dim*(NCOL+1) 1]);
rows        = reshape(rows, [dim*(NCOL+1)*dim*NTST 1]);
cols        = repmat(1:dim*(NCOL+1)*NTST, [dim 1]);
cols        = reshape(cols, [dim*(NCOL+1)*dim*NTST 1]);

Wc          = repmat(int.Wc, [1 NTST]);
Wc          = reshape(Wc, [dim*(NCOL+1)*dim*NTST 1]);
maps.Wc     = sparse(rows, cols, Wc);
maps.wn     = int.wn;

end
