% Test variants of sparse factorisation and determinant computation.

% current_spparms = spparms();
% spparms('umfpack', 0);
% mldivide uses:
% thresh = [0.1, 0.001];
% [L,U,P,Q,R] = lu(A, thresh); % we have P*(R\A)*Q = L*U
%                              % with this we get X = Q*(U\L\(P*(R\B)))
%                              % or, use X = linsolve(A,B,opts)

% b = b/norm(b);

% load ../bwred/lutest-small
% load ../bwred/lutest-medium
load ../bwred/lutest-large
% A = sprand(100,100,0.11); b = rand(100,1);

tic; x = A\b; toc

tic
thresh = [0.1 0.001];
% thresh = [1 1];
[L,U,P,Q,R] = lu(A, thresh);
% X = Q*(U\L\(P*(R\b)));
toc
X = Q*(U\(L\(P*(R\b))));
toc

fprintf('norm(x-X)/norm(x) = %.2e\n', norm(x-X)/norm(x));

% scaling OK, sign OK
DR  = full(diag(R));
SR  = prod(sign(DR));
DU  = full(diag(U));
SU  = prod(sign(DU));
DPQ = det(P)*det(Q);
sru = sort(sort(abs(DR)).*sort(abs(DU),'descend'));
N   = 10;
sc  = 2*( sru(1:N)./(max(sru(1:N))+sru(1:N)) );
pr  = DPQ*SR*SU*prod(sc);
fprintf('prod(sru(1:%d)) = %.2e\n', N, pr);

if size(A,1)<=1000
  fprintf('prod(sru) = %.6e\n', DPQ*SR*SU*prod(sru));
  fprintf('det (A)   = %.6e\n', prod(eig(full(A))) );
end

fprintf('condest(A) = %.6e\n', condest(A));
ca = max(abs(diag(R)))/min(abs(diag(R)));
ca = ca * max(abs(diag(L)))/min(abs(diag(L)));
ca = ca * max(abs(diag(U)))/min(abs(diag(U)));
fprintf('cond(A) <= %.6e\n', full(ca));
