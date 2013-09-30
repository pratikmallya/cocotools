function sol = dft_init_sol(data, t0, x0, p0)

N    = 2*data.dft.NMAX+2;
NMOD = data.dft.NMOD;

t0 = t0(:);
T0 = t0(end)-t0(1);
t0 = (t0-t0(1))/T0;
x0 = interp1(t0, x0, (0:N-1)'/N)';

x0 = fft(x0.').';
x0 = x0(:,1:NMOD+1)/N;
xh = [real(x0(:,2:end)); imag(x0(:,2:end))];
x0 = [x0(:,1) reshape(xh, [size(x0,1) 2*NMOD])];

sol.x0 = x0;
sol.T0 = T0;
sol.p0 = p0;
sol.u0 = [x0(:); zeros(size(x0,1)*(N-2*NMOD-2),1); T0; p0];

end