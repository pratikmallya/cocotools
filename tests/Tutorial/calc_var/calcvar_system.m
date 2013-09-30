function [data x0] = calcvar_system(data, p0)

NTST  = data.NTST;
NCOL  = data.NCOL;

data.tk = linspace(-1, 1, NCOL+1);
[data.th wt] = coll_nodes(NCOL);

tt = (0:NTST-1)' / NTST;
t  = repmat(data.tk, [NTST 1]);
t  = (t+1) * 0.5/NTST;
t  = t + repmat(tt, [1 NCOL+1]);
t  = reshape(t', [NTST*(NCOL+1) 1]);
t  = t./t(end);
data.tbp = t;

if isfield(data, 't0') && ~isempty(data.t0)
    t0 = data.t0;
    x0 = data.x0;
    T0 = t0(end) - t0(1);
    t0 = (t0 - t0(1)) / T0;
    x0 = interp1(t0, x0, t)';
else
    x0 = data.stpnt(t');
end

x0    = reshape(x0, [(NCOL+1)*NTST 1]);
pdim  = numel(p0);

data.wt = repmat(reshape(wt', [NCOL 1]), [NTST 1]);
data.wt = spdiags(data.wt,0,NTST*NCOL,NTST*NCOL);

data.x_idx  = 1:(NCOL+1)*NTST;
data.p_idx  = (NCOL+1)*NTST + (1:pdim);

intidx         = (1:NTST*(NCOL+1))';
intidx         = reshape(intidx, [NCOL+1, NTST]);
data.fint1_idx = intidx(end,1:end-1);
data.fint2_idx = intidx(1,2:end);
intidx         = intidx(2:end,:);
intidx         = reshape(intidx, [NTST*NCOL, 1]);
data.fint3_idx = intidx(1:end-1);

temp        = reshape(1:(NCOL+1)*NTST, [NCOL+1 NTST]);
ipidx       = reshape(temp(1, 2:end),[1 NTST-1]);
epidx       = reshape(temp(NCOL+1:end, 1:end-1),[1 NTST-1]);

rows        = [1:(NTST-1) 1:(NTST-1)];
cols        = [ipidx epidx];
vals        = [ones(1,NTST-1) -ones(1,NTST-1)];
data.Q      = sparse(rows, cols, vals, NTST-1, (NCOL+1)*NTST);

rows        = reshape(1:NCOL*NTST, [NCOL NTST]);
rows        = repmat(rows, [NCOL+1 1]);
rows        = reshape(rows, [(NCOL+1)*NCOL*NTST 1]);
cols        = repmat(1:(NCOL+1)*NTST, [NCOL 1]);
cols        = reshape(cols, [(NCOL+1)*NCOL*NTST 1]);

pmap        = coll_L(data.tk, data.th);
dmap        = coll_Lp(data.tk, data.th);
W           = repmat(pmap, [1 NTST]);
W           = reshape(W, [(NCOL+1)*NCOL*NTST 1]);
Wp          = repmat(dmap, [1 NTST]);
Wp          = reshape(Wp, [(NCOL+1)*NCOL*NTST 1]);
data.W      = sparse(rows, cols, W);
data.Wp     = sparse(rows, cols, Wp);

end

function [x, w] = coll_nodes(n)

nn = 1:n-1;
ga = -nn.*sqrt(1./(4.*nn.^2-1));
J  = zeros(n,n);
J(sub2ind([n n], nn, nn+1)) = ga;
J(sub2ind([n n], nn+1, nn)) = ga;

[w,x] = eig(J);

x = diag(x);
w = 2*w(1,:)'.^2;

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