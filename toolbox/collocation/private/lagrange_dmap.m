function A = lagrange_dmap(n, tk, th)
%Linear mapping from interpolation to derivative at collocation points.
%
%   A = LAGRANGE_DMAP(N,TK,TH) computes the linear mapping from N+1
%   interpolation or base points to the time-derivatives at N collocation
%   points. The returned matrix A has format n(N+1) x nN, where n is the
%   dimension of the phase space.
%

if nargin<3
	n  = 2;
	tk = lagrange_bpoints(4, 'linspace'); % 'linspace', 'tschebycheff'
	th = gaussnodes(3);
end

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
A = kron(A, eye(n,n));
