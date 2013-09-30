function int = coll_interval(NCOL, dim)

int.NCOL    = NCOL;
int.dim     = dim;

int.tk      = linspace(-1, 1, NCOL+1);
[int.th wt] = coll_nodes(NCOL);

wt     = repmat(wt, [dim 1]);
int.wt = reshape(wt, [dim*NCOL 1]);

pmap   = coll_L(int.tk, int.th);
int.W  = kron(pmap, eye(dim));
dmap   = coll_Lp(int.tk, int.th);
int.Wp = kron(dmap, eye(dim));
[cmap int.wn] = coll_Lc(int.tk);
int.Wc = kron(cmap, eye(dim));

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
