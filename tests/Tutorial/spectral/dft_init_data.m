function data = dft_init_data(data, sol)

N = 2*data.dft.NMAX+2;

dim  = size(sol.x0,1);
pdim = numel(sol.p0);
data.dim   = dim;
data.pdim  = pdim;
data.T_idx = dim*(N-1)+1;
data.p_idx = dim*(N-1)+1+(1:pdim)';
data.p_rep = [1 N];
data.x_shp = [dim N];

data.Forig  = (1/N)*fft(eye(N));
Finv        = N*ifft(eye(N));
data.Fsorig = kron(data.Forig, speye(dim));
data.Finvs  = kron(Finv, speye(dim));

data.dxrows = repmat(reshape(1:dim*N, [dim N]), [dim 1]);
data.dxcols = repmat(1:dim*N, [dim 1]);
data.dprows = repmat(reshape(1:dim*N, [dim N]), [pdim 1]);
data.dpcols = repmat(1:pdim, [dim N]);

data = dft_init_modes(data, sol);

end