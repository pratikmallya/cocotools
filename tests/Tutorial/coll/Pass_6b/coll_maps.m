function maps = coll_maps(int, NTST, pdim)

NCOL = int.NCOL;
dim  = int.dim;

maps.NTST = NTST;
maps.pdim = pdim;

bpnum  = NCOL+1;
bpdim  = dim*(NCOL+1);
xbpnum = (NCOL+1)*NTST;
xbpdim = dim*(NCOL+1)*NTST;
cndim  = dim*NCOL;
xcnnum = NCOL*NTST;
xcndim = dim*NCOL*NTST;
cntnum = NTST-1;
cntdim = dim*(NTST-1);

maps.xbp_idx  = (1:xbpdim)';
maps.T_idx    = xbpdim+1;
maps.p_idx    = xbpdim+1+(1:pdim)';
maps.ka_idx   = xbpdim+1+pdim+(1:NTST)';
maps.la_idx   = xbpdim+1+pdim+NTST+1;
maps.Tp_idx   = [maps.T_idx; maps.p_idx];
maps.fka_idx  = kron(1:NTST, ones(dim, NCOL));
maps.dxka_idx = reshape(kron(maps.fka_idx, ones(1, dim)), ...
  [dim dim NCOL*NTST]);
maps.dpka_idx = reshape(kron(maps.fka_idx, ones(1,pdim)), ...
  [dim pdim NCOL*NTST]);
maps.tbp_idx  = setdiff(1:xbpnum, 1+bpnum*(1:cntnum))';

maps.x_shp   = [dim xcnnum];
maps.xbp_shp = [dim xbpnum];
maps.v_shp   = [int.dim int.NCOL+1 maps.NTST];
maps.p_rep   = [1 xcnnum];

rows         = reshape(1:xcndim, [cndim NTST]);
rows         = repmat(rows, [bpdim 1]);
cols         = repmat(1:xbpdim, [cndim 1]);
W            = repmat(int.W, [1 NTST]);
Wp           = repmat(int.Wp, [1 NTST]);
maps.W       = sparse(rows, cols, W);
maps.Wp      = sparse(rows, cols, Wp);

temp         = reshape(1:xbpdim, [bpdim NTST]);
Qrows        = [1:cntdim 1:cntdim];
Qcols        = [temp(1:dim, 2:end) temp(cndim+1:end, 1:end-1)];
Qvals        = [ones(cntdim,1) -ones(cntdim,1)];
maps.Q       = sparse(Qrows, Qcols, Qvals, cntdim, xbpdim);
maps.Qnum    = cntdim;

maps.dxrows  = repmat(reshape(1:xcndim, [dim xcnnum]), [dim 1]);
maps.dxcols  = repmat(1:xcndim, [dim 1]);
maps.dprows  = repmat(reshape(1:xcndim, [dim xcnnum]), [pdim 1]);
maps.dpcols  = repmat(1:pdim, [dim xcnnum]);
maps.karows  = 1:xcndim;

maps.x0_idx  = (1:dim)';
maps.x1_idx  = xbpdim-dim+(1:dim)';

rows         = reshape(1:dim*NTST, [dim NTST]);
rows         = repmat(rows, [bpdim 1]);
cols         = repmat(1:xbpdim, [dim 1]);
Wm           = repmat(int.Wm, [1 NTST]);
maps.Wm      = sparse(rows, cols, Wm);
x            = linspace(int.tm(1), int.tm(2), 51);
y            = arrayfun(@(x) prod(x-int.tm), x);
maps.wn      = max(abs(y));

end