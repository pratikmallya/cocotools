function [t1 t2] = time_linsolveB(M, N, A, b)

cols = 1:N;
for i=1:M
  idx       = round(1 + (N-i)*rand);
  col(i)    = cols(idx); %#ok<AGROW>
  cols(idx) = [];
end

rows = [  N+(1:M) ;    N+(1:M)];
cols = [      col ;    N+(1:M)];
vals = [ones(1,M) ; -ones(1,M)];

colperm = 1:N+M;
colperm([cols(1,:) cols(2,:)]) = colperm([cols(2,:) cols(1,:)]);

[r c v] = find(A);

r = [r ; rows(:)];
c = colperm([c ; cols(:)]);
v = [v ; vals(:)];

AA = sparse(r,c,v, N+M, N+M);
bb = [b ; zeros(M,1)];

parms = spparms();
spparms('piv_tol', 1.0);

t1 = cputime;
x = A\b;
t1 = cputime-t1;

t2 = cputime;
xx = AA\bb;
t2 = cputime-t2;
xx(colperm) = xx;

spparms(parms);

fprintf('elapsed times: %.2e %.2e secs, diff=%.2e\n', t1, t2, ...
  max(abs(x - xx(1:N))));
