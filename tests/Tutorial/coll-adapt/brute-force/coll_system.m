function [data x1 dx1] = coll_system(data, t0, x0, p0, dx0, dT0)

NTST = data.coll.NTST;
NCOL = data.coll.NCOL;
dim  = size(x0,2);
pdim = numel(p0);

data.tk = linspace(-1, 1, NCOL+1);
[data.th wt] = coll_nodes(NCOL);

tt = (0:NTST-1)' / NTST;
t  = repmat(data.tk, [NTST 1]);
t  = (t+1) * 0.5/NTST;
t  = t + repmat(tt, [1 NCOL+1]);
t  = reshape(t', [NTST*(NCOL+1) 1]);
t  = t./t(end);
data.tbp = t;

T0  = t0(end) - t0(1);
if abs(T0)>eps
  t0  = (t0 - t0(1)) / T0;
  x1  = interp1(t0,  x0, t)';
  dx1 = interp1(t0, dx0, t)';
  dx1 = dx1*(norm(dx0(:))/norm(dx1(:)));
else
  x1  = repmat( x0(1,:), size(t))';
  dx1 = repmat(dx0(1,:), size(t))';
end
x1  = [ x1(:) ;  T0];
dx1 = [dx1(:) ; dT0];

data.dim  = dim;
data.pdim = pdim;

wt = repmat(wt, [dim 1]);
data.wt = repmat(reshape(wt, [dim*NCOL 1]), [NTST 1]);

data.x_idx  = 1:dim*(NCOL+1)*NTST + 1;
data.p_idx  = dim*(NCOL+1)*NTST + 1 + (1:pdim);

data.xbpidx = 1:dim*(NCOL+1)*NTST;
data.Tidx   = dim*(NCOL+1)*NTST+1;

dup_idx  = 1+((NCOL+1):(NCOL+1):((NCOL+1)*NTST-1));
tbp_uidx = 1:(NCOL+1)*NTST;
tbp_uidx(dup_idx) = [];
data.tbp_uidx = tbp_uidx;

data.xx_shape = [dim NTST*NCOL];
data.pp_shape = [1 NTST*NCOL];

dxrows      = reshape(1:dim*NCOL*NTST, [dim NCOL*NTST]);
dxrows      = repmat(dxrows, [dim 1]);
data.dxrows = reshape(dxrows, [dim*dim*NCOL*NTST 1]);

dxcols      = repmat(1:dim*NCOL*NTST, [dim 1]);
data.dxcols = reshape(dxcols, [dim*dim*NCOL*NTST 1]);

data.frows  = 1:dim*NTST*NCOL;
data.fcols  = repmat(dim*(NCOL+1)*NTST+1, [dim*NTST*NCOL,1]);
data.off    = dim*NTST*NCOL;

dprows      = reshape(1:dim*NCOL*NTST, [dim NCOL*NTST]);
dprows      = repmat(dprows, [pdim 1]);
data.dprows = reshape(dprows, [dim*NCOL*NTST*pdim 1]);

dpcols      = repmat(1:pdim, [dim 1]);
dpcols      = repmat(dpcols, [1 NCOL*NTST]);
data.dpcols = reshape(dpcols, [dim*NCOL*NTST*pdim 1]);

temp        = reshape(1:dim*(NCOL+1)*NTST, [dim*(NCOL+1) NTST]);
data.x0idx  = temp(1:dim,1);
data.x1idx  = temp(dim*NCOL+1:end,end);
ipidx       = reshape(temp(1:dim, 2:end),[1 dim*(NTST-1)]);
epidx       = reshape(temp(dim*NCOL+1:end, 1:end-1),[1 dim*(NTST-1)]);

data.Qrows  = [1:dim*(NTST-1) 1:dim*(NTST-1)];
data.Qcols  = [ipidx epidx];
data.Qvals  = [ones(1,dim*(NTST-1)) -ones(1,dim*(NTST-1))];
data.Q      = sparse(data.Qrows, data.Qcols, data.Qvals, ...
  dim*(NTST-1), dim*(NCOL+1)*NTST);

rows        = reshape(1:dim*NCOL*NTST, [dim*NCOL NTST]);
rows        = repmat(rows, [dim*(NCOL+1) 1]);
rows        = reshape(rows, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
cols        = repmat(1:dim*(NCOL+1)*NTST, [dim*NCOL 1]);
cols        = reshape(cols, [dim*(NCOL+1)*dim*NCOL*NTST 1]);

pmap        = coll_L(data.tk, data.th);
dmap        = coll_Lp(data.tk, data.th);
W           = repmat(kron(pmap, eye(dim)), [1 NTST]);
W           = reshape(W, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
Wp          = repmat(kron(dmap, eye(dim)), [1 NTST]);
Wp          = reshape(Wp, [dim*(NCOL+1)*dim*NCOL*NTST 1]);
data.W      = sparse(rows, cols, W);
data.Wp     = sparse(rows, cols, Wp);

rows        = reshape(1:dim*NTST, [dim NTST]);
rows        = repmat(rows, [dim*(NCOL+1) 1]);
rows        = reshape(rows, [dim*(NCOL+1)*dim*NTST 1]);
cols        = repmat(1:dim*(NCOL+1)*NTST, [dim 1]);
cols        = reshape(cols, [dim*(NCOL+1)*dim*NTST 1]);

[cmap data.wn] = coll_Lc(data.tk);
Wc          = repmat(kron(cmap, eye(dim)), [1 NTST]);
Wc          = reshape(Wc, [dim*(NCOL+1)*dim*NTST 1]);
data.Wc     = sparse(rows, cols, Wc);

end

function [x, w] = coll_nodes(n)

nn = 1:n-1;
ga = -nn.*sqrt(1./(4.*nn.^2-1));
J  = zeros(n,n);
J(sub2ind([n n], nn, nn+1)) = ga;
J(sub2ind([n n], nn+1, nn)) = ga;

[w,x] = eig(J);

x = diag(x);
w = 2*w(1,:).^2;

end

function A = coll_L(tk, th)

q = length(tk);
p = length(th);

ti = reshape(tk, [1 1 q]);
tk = reshape(tk, [1 q 1]);
th = reshape(th, [p 1 1]);

ti = repmat(ti, [p q 1]);
tk = repmat(tk, [p 1 q]);
th = repmat(th, [1 q q]);

tki = tk-ti;
thi = th-ti;

idx = find(abs(tki)<=eps);

thi(idx) = 1;
tki(idx) = 1;

A = thi./tki;
A = prod(A, 3);

A = reshape(A, [p q]);

end

function A = coll_Lp(tk, th)

q = length(tk);
p = length(th);

tj = reshape(tk, [1 1 q]);
tj = repmat (tj, [p q 1]);

ti = reshape(tk, [1 1 1 q]);
tk = reshape(tk, [1 q 1 1]);
th = reshape(th, [p 1 1 1]);

ti = repmat(ti, [p q q 1]);
tk = repmat(tk, [p 1 q q]);
th = repmat(th, [1 q q q]);

tki = tk-ti;
tkj = tk(:,:,:,1)-tj;
thi = th-ti;

idx1 = find(abs(tki)<=eps);
idx2 = find(abs(tkj)<=eps);
idx3 = find(abs(repmat(tj, [1 1 1 q])-ti)<=eps);

tki(idx1) = 1;
tki(idx3) = 1;
thi(idx1) = 1;
thi(idx3) = 1;

tkj(idx2) = 1;
tkj       = 1.0 ./ tkj;
tkj(idx2) = 0;

A = thi ./ tki;
A = prod(A, 4);

A = reshape(A, [p q q]);
A = tkj .* A;
A = sum(A, 3);

A = reshape(A, [p q]);

end

function [A wn] = coll_Lc(tk)

p = length(tk);

f  = @(x) prod(x-tk);
% for equidistributed interpolation points the global extrema lie in the
% outermost intervals, this needs to be adjusted for other distributions
x  = linspace(tk(1),tk(2),51);
y  = arrayfun(f, x);
% plot(x,y,'.-'); grid on;
wn = max(abs(y));

ti = reshape(tk, [1 p]);
tk = reshape(tk, [p 1]);

ti = repmat(ti, [p 1]);
tk = repmat(tk, [1 p]);

tki = tk-ti;

idx = abs(tki)<=eps;

tki(idx) = 1;

A = 1./tki;
A = prod(A, 2);

A = reshape(A, [1 p]);

end
