% mldivide uses:
% thresh = [0.1, 0.001];
% [L,U,P,Q,R] = lu(A, thresh); % we have P*(R\A)*Q = L*U
%                              % with this we get X = Q*(U\L\(P*(R\B)))
%                              % or, use X = linsolve(A,B,opts)

% NDIM=2, NTST=10000, NCOL=4
% granularity: 10000x10, 3

% tic; x=A\b; toc % 24sec

[r c v] = find(A);
[m n]   = size(A);

r1 = r((r<m));
c1 = c((r<m));
v1 = v((r<m));

r2 = r((r>=m));
c2 = c((r>=m));
v2 = v((r>=m));

r3 = r2;
c3 = c2;
v3 = v2;

idx  = 0:9;
roff = 0;
for i=1:10:n-3
  bidx = i+idx;
  r3(bidx) = r3(bidx)+roff;
  roff=roff+1;
end

rr = m+(0:roff-1);
cc = n+(1:roff);

% rr = [rr rr rr m+roff];
% cc = [circshift(cc,[0 1]) cc circshift(cc,[0 -1]) n+roff];
% vv = [ones(1,roff) -2*ones(1,roff) ones(1,roff) 1];
% b2 = [b;zeros(roff,1)];

% rr = [rr rr m+roff];
% cc = [circshift(cc,[0 1]) cc n+roff];
% vv = [ones(1,roff) -ones(1,roff) 1];
% b2 = [b;zeros(roff,1)];

rr = [rr(2:end) rr m+roff];
cc = [cc(1:end-1) cc n+roff];
vv = [ones(1,roff-1) -ones(1,roff) 1];
b2 = [b(1:end-1);zeros(roff,1);b(end)];

A1 = sparse([r1;r2], [c1;c2], [v1;v2]);
A2 = sparse([r1;r3;rr'], [c1;c3;cc'], [v1;v3;vv']);

b1 = b;

% spparms('piv_tol', 0.5) % default: 0.1
tic; x1=A1\b1; toc
tic; x2=A2\b2; toc
% spparms('default')

max(abs(x1-x2(1:n)))

% condest(A1) = 6.4053e+05
