function prob = interp_isol2curve(prob, N, s, fhan, p0)

data.N     = N;
data.pdim  = numel(p0);
data.x_idx = 1:N;
data.p_idx = N+(1:data.pdim);
data.xtr   = zeros(N+data.pdim,1);
data.xtr([1 N data.p_idx]) = [1 N data.p_idx];
data.th    = linspace(-1,1,N)';
data.sg    = s;
data.fhan  = fhan;
data.t     = data.th;

u0  = data.fhan(data.t', repmat(p0, [1 N]))';
uu  = 2*(u0-u0(1))/(u0(end)-u0(1))-1+data.sg*data.t;
uu  = 2*(uu-uu(1))/(uu(end)-uu(1))-1;
t0  = interp1(uu, data.t, data.th);
data.t = t0;
u0  = data.fhan(data.t', repmat(p0, [1 N]))';
sol = [u0; p0];

prob = interp_construct_curve(prob, data, sol);

end