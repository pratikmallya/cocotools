function data = floquet_system(data, x0)

dim  = data.dim;
NTST = data.NTST;
NCOL = data.NCOL;
pdim = numel(data.p_idx);

rows = reshape(1:dim*dim*NCOL*NTST, [dim*dim NTST*NCOL]); % n^2 x Nm
rows = repmat(rows, [dim 1]); % n^3 x Nm
data.dxdxrows1 = reshape(rows, [dim*dim*dim*NTST*NCOL 1]); % n^3*Nm x 1
cols = repmat(1:dim*NCOL*NTST, [dim*dim 1]); % n^2 x nNm
data.dxdxcols1 = reshape(cols, [dim*dim*dim*NTST*NCOL 1]); % n^3*Nm x 1

cols = repmat(1:dim*NCOL*NTST, [dim 1]); % n x nNm
cols = reshape(cols, [dim*dim*NCOL*NTST 1]); %n^2*Nm
data.dxdxcols2 = repmat(cols, [dim*NTST*(NCOL+1) 1]); % n^3*N^2*m(m+1) x 1
rows = reshape(1:dim*dim*NTST*NTST*NCOL*(NCOL+1), [dim dim*NTST*NTST*NCOL*(NCOL+1)]);  % n x nN^2*m(m+1)
rows = repmat(rows, [dim 1]); % n^2 x nN^2*m(m+1)
data.dxdxrows2 = reshape(rows, [dim*dim*dim*NTST*NTST*NCOL*(NCOL+1) 1]); % n^3*N^2*m(m+1) x 1

cols = repmat(1:dim*NTST*(NCOL+1), [dim*NTST*NCOL 1]); % nNm x nN(m+1)
cols = reshape(cols, [dim*dim*NTST*NTST*NCOL*(NCOL+1) 1]); % n^2*N^2*m(m+1) x 1
data.dxdxcols3 = repmat(cols, [dim 1]); % n^3*N^2*m(m+1) x 1
rows = reshape(1:dim*dim*NCOL*NTST, [dim*NTST*NCOL dim]); % nNm x n
rows = repmat(rows, [dim*NTST*(NCOL+1) 1]); % n^2*N^2*m(m+1) x n
data.dxdxrows3 = reshape(rows, [dim*dim*dim*NTST*NTST*NCOL*(NCOL+1) 1]); % n^3*N^2*m(m+1) x 1

cols = repmat(1:dim*NCOL*NTST, [dim 1]); % n x nNm
cols = reshape(cols, [dim*dim*NCOL*NTST 1]); %n^2*Nm
data.dxdpcols1 = repmat(cols, [pdim 1]); % n^2*Nmp x 1
rows = reshape(1:dim*NTST*NCOL*pdim, [dim NTST*NCOL*pdim]);  % n x Nmp
rows = repmat(rows, [dim 1]); % n^2 x Nmp
data.dxdprows1 = reshape(rows, [dim*dim*NTST*NCOL*pdim 1]); % n^2*Nmp x 1

cols = repmat(1:pdim, [dim*NTST*NCOL 1]); % nNm x p
cols = reshape(cols, [dim*NTST*NCOL*pdim 1]); % nNmp x 1
data.dxdpcols2 = repmat(cols, [dim 1]); % n^2*Nmp x 1
rows = reshape(1:dim*dim*NCOL*NTST, [dim*NTST*NCOL dim]); % nNm x n
rows = repmat(rows, [pdim 1]); % nNmp x n
data.dxdprows2 = reshape(rows, [dim*dim*NTST*NCOL*pdim 1]); % n^2*Nmp x 1

xbp0       = x0(data.xbpidx);
data.x0  = data.W * xbp0;
xp0      = data.Wp * xbp0;
xp0      = data.wt .* xp0;
data.xp0 = xp0';

Omega   = spdiags(data.wt,0,dim*NTST*NCOL,dim*NTST*NCOL);
data.B1 = sparse([eye(dim) zeros(dim,NTST*(NCOL+1)*dim-2*dim) eye(dim)]);
data.B2 = (0.5 / NTST) * data.W' * Omega * data.W;
ubp0    = reshape(x0(data.u_idx), data.var2x0reshape);
data.B  = data.B1 + ubp0' * data.B2;
data.Id = reshape(eye(dim), [dim*dim 1]);

data.dfdxhan = str2func(sprintf('%s_DFDX2', func2str(data.fhan)));
data.dfdphan = str2func(sprintf('%s_DFDP2', func2str(data.fhan)));
data.dfdxdxhan = str2func(sprintf('%s_DFDXDX', func2str(data.fhan)));
data.dfdxdphan = str2func(sprintf('%s_DFDXDP', func2str(data.fhan)));

end