function A = lagrange_pmap(n, tk, th)
%Linear mapping from interpolation to collocation points.
%
%   A = LAGRANGE_PMAP(N,TK,TH) computes the linear mapping from N+1
%   interpolation or base points to N collocation points. The returned
%   matrix A has format n(N+1) x nN, where n is the dimension of the phase
%   space.
%

if nargin<3
	n  = 2;
	tk = lagrange_bpoints(4, 'linspace'); % 'linspace', 'tschebycheff'
	th = gaussnodes(3);
end

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
A = kron(A, eye(n,n));
