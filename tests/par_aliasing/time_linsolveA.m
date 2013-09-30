function [t1 t2] = time_linsolveA(M, N, A, b)

cols = 1:N;
for i=1:M
  idx       = round(1 + (N-i)*rand);
  col(i)    = cols(idx); %#ok<AGROW>
  cols(idx) = [];
end

rows = [      1:M ;       1:M ];
cols = [    M+col ;       1:M ];
vals = [ones(1,M) ; -ones(1,M)];

[r c v] = find(A);

r = [M+r ; rows(:)];
c = [M+c ; cols(:)];
v = [v ; vals(:)];

AA = sparse(r,c,v, N+M, N+M);
bb = [zeros(M,1) ; b];

parms = spparms();
spparms('piv_tol', 1.0);

t1 = cputime;
x = A\b;
t1 = cputime-t1;

t2 = cputime;
xx = AA\bb;
t2 = cputime-t2;
xx = xx(M+1:end);

spparms(parms);

fprintf('elapsed times: %.2e %.2e secs, diff=%.2e\n', t1, t2, ...
  max(abs(x - xx(1:N))));
