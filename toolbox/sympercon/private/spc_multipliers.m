function [data varargout] = spc_multipliers(opts, data, x) %#ok<INUSL>
% Compute Floquet multipliers for segmented periodic orbit.

M0s     = reshape(x(data.m0idx), data.mshape);
M1s     = reshape(x(data.m1idx), data.mshape);

% mignore = x(data.mignore_idx);
% rs      = mignore(data.mignore_r);
% phis    = mignore(data.mignore_phi);
% mignore(data.mignore_r  ) = rs.*(cos(phis)+1i*sin(phis));
% mignore(data.mignore_phi) = rs.*(cos(phis)-1i*sin(phis));
% mignore = [ mignore ; 1 ; 0 ];

mignore = [ 1 ; 0 ];

[varargout{1:nargout-1}] = preig(M1s, M0s, mignore);

end

function varargout = preig(As, Bs, mignore)
% Solve (generalised) product matrix eigenvalue problem.

if nargin<2
	Bs = [];
end

n  = size(As,1);
N  = size(As,3);
nn = n*N;
A  = zeros(nn,nn);

subs = reshape(1:nn, [n N]);
rows = subs(:,[1 end:-1:2]);
cols = subs(:,end:-1:1);

for i=1:N
	A(rows(:,i),cols(:,i)) = As(:,:,N-i+1);
end

if ~isempty(Bs)
	B  = zeros(nn,nn);

	rows = subs(:,end:-1:1);
	cols = subs(:,end:-1:1);

	for i=1:N
		B(rows(:,i),cols(:,i)) = Bs(:,:,N-i+1);
	end
end

if nargout<=1
	if isempty(Bs)
		evals = eig(A).^N;
	else
		evals = eig(A,B).^N;
	end
	ev1   = repmat(evals, [1 nn]);
	ev2   = ev1.';
	devs  = abs(ev1-ev2);

	DD = zeros(n,1);
	for i = 1:n
		[B idx]          = sort(devs(1,:)); %#ok<ASGLU>
		DD(i)            = sum(evals(idx(1:N)))/N;
		devs(:,idx(1:N)) = [];
		devs(idx(1:N),:) = [];
		evals(idx(1:N))  = [];
  end
	
  for i=1:numel(mignore)
    [d idx]   = sort(abs(DD(i:end)-mignore(i))); %#ok<ASGLU>
    DD(i:end) = DD(i+idx-1);
  end
  varargout{1} = DD;
else
	if isempty(Bs)
		[X D] = eig(A);
	else
		[X D] = eig(A,B);
	end
	evals = diag(D.^N);
	ev1   = repmat(evals, [1 nn]);
	ev2   = ev1.';
	devs  = abs(ev1-ev2);

	DD = zeros(n,1);
	XX = zeros(n,n);
	for i = 1:n
		[B idx]          = sort(devs(1,:)); %#ok<ASGLU>
		DD(i)            = sum(evals(idx(1:N)))/N;
		XX(:,i)          = X(1:n,idx(1));
		devs(:,idx(1:N)) = [];
		devs(idx(1:N),:) = [];
		evals(idx(1:N))  = [];
		X(:,idx(1:N))    = [];
	end

	for i = 1:n
		if isreal(DD(i))
			if norm(real(XX(:,i)))>norm(imag(XX(:,i)))
				XX(:,i) = real(XX(:,i));
			else
				XX(:,i) = imag(XX(:,i));
			end
		end
		XX(:,i) = XX(:,i)/norm(XX(:,i),2);
	end
	
  for i=1:numel(mignore)
    [d idx]     = sort(abs(DD(i:end)-mignore(i))); %#ok<ASGLU>
    DD(i:end)   = DD(i+idx-1);
    XX(:,i:end) = XX(:,i+idx-1);
  end
	varargout{1} = XX;
	varargout{2} = diag(DD);
end

end

%%
function [DD] = peig(As, Bs) %#ok<DEFNU>

k = size(As,3);
if nargin<2
  for i=1:k
    M0{i} = squeeze(As(:,:,k-i+1)); %#ok<AGROW>
  end
  As = M0;
  Bs = {};
else
  for i=1:k
    M0{i} = squeeze(As(:,:,k-i+1)); %#ok<AGROW>
    M1{i} = squeeze(Bs(:,:,k-i+1)); %#ok<AGROW>
  end
  As = M0;
  Bs = M1;
end


n  = size(As{1},1);
N  = numel(As);
nn = n*N;
A  = zeros(nn,nn);

subs = reshape(1:nn, [n N]);
rows = subs(:,[1 end:-1:2]);
cols = subs(:,end:-1:1);

for i=1:N
	A(rows(:,i),cols(:,i)) = As{i};
end

if ~isempty(Bs)
	B  = zeros(nn,nn);

	rows = subs(:,end:-1:1);
	cols = subs(:,end:-1:1);

	for i=1:N
		B(rows(:,i),cols(:,i)) = Bs{i};
	end
end

if isempty(Bs)
	evals = eig(A).^N;
else
	evals = eig(A,B).^N;
end
ev1   = repmat(evals, [1 nn]);
ev2   = ev1.';
devs  = abs(ev1-ev2);

DD = zeros(n,1);
for i = 1:n
	[B idx]          = sort(devs(1,:)); %#ok<ASGLU>
	DD(i)            = sum(evals(idx(1:N)))/N;
	devs(:,idx(1:N)) = [];
	devs(idx(1:N),:) = [];
	evals(idx(1:N))  = [];
end

end
