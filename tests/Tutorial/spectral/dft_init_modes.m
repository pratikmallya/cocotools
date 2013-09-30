function data = dft_init_modes(data, sol)

N    = 2*data.dft.NMAX+2;
NMOD = data.dft.NMOD;
dim  = data.dim;

mdim = dim*(2*NMOD+1);
ddim = dim*(N-2*NMOD-2);
data.mdim   = mdim;
data.ddim   = ddim;
data.xf_idx = 1:data.mdim;
data.xd_idx = data.mdim+(1:data.ddim)';

phs = repmat(1:NMOD, [dim 1]);
phs = [-phs; phs].*[sol.x0(:,3:2:end); sol.x0(:,2:2:end)];
data.phs = [zeros(dim,1); phs(:)]';
row = sparse(1:ddim, 1+mdim:ddim+mdim, ones(1,ddim), ddim, data.T_idx);
data.jac = [row; data.phs, sparse(1,ddim+1)];

D           = 2*pi*1i*diag([0:NMOD zeros(1,N-2*NMOD-2+1) -NMOD:-1]);
Ds          = kron(D, speye(dim));
W           = kron([1, zeros(1,2*NMOD);
  zeros(N-1,1), [kron(speye(NMOD), [1 1i]);
  zeros(N-2*NMOD-1,2*NMOD);
  kron(fliplr(speye(NMOD)), [1 -1i])]], speye(dim));
data.Wp     = Ds(1:dim*(NMOD+1),:)*W;
data.F      = data.Forig(:,NMOD+2:N/2+1);
data.Fs     = data.Fsorig(1:dim*(NMOD+1),:);
data.FinvsW = real(data.Finvs*W);

end