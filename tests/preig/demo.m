format short e

N = 15 %#ok<NOPTS>

g = 2/(1+sqrt(5));

C  = [
	1/2  -g  0 0
	 g   1/2 0 0
	 0    0  1 0
	 0    0  0 2
	 ];

X  = [1 1 1 1; 1.001 1 1 1; 1 1.001 1 1; 1 1 1 1.001];

for i=1:4
	X(:,i) = X(:,i)/norm(X(:,i));
end

Xi = inv(X); % create ill-conditioned product matrix eigenvalue problem
B  = Xi*C*X;
AA = eye(size(B));

clear A
for i=1:N
  A{i} = B; %#ok<UNRCH,AGROW>
	AA   = AA*B;
end

% compute exact eigensystem for product matrix
[evals idx] = sort([
	1/2+sqrt(-1)*g
	1/2-sqrt(-1)*g
	1
	2
	].^N);

evecs = Xi*[
	-sqrt(-0.5) sqrt(-0.5) 0 0
	 sqrt( 0.5) sqrt( 0.5) 0 0
	     0          0      1 0
	     0          0      0 1
	];
evecs = evecs(:,idx);
for i=1:4
	evecs(:,i) = evecs(:,i)/norm(evecs(:,i));
end

[X1 ev1]   = preig(A); % product matrix algorithm
[ev1 idx1] = sort(diag(ev1));
X1         = X1(:,idx1);

[X2 ev2]   = eig(AA); % eigenvalues of product matrix
[ev2 idx2] = sort(diag(ev2));
X2         = X2(:,idx2);

err1  = abs(evals-ev1)./abs(evals);
err2  = abs(evals-ev2)./abs(evals);

% errors in eigenvalues

err_evals = [evals ev1 err1 ev2 err2] %#ok<NOPTS>

idx1 = [1:8 10 11 15 16];
idx2 = [9 12 13 14];

% errors in eigenvectors

err_evecs = ...
	[ max([abs(evecs(idx1)./X1(idx1))-1 abs(evecs(idx2)-X1(idx2))]) ...
		max([abs(evecs(idx1)./X2(idx1))-1 abs(evecs(idx2)-X2(idx2))]) ] %#ok<NOPTS>
