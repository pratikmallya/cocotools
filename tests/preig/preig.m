function varargout = preig(As, Bs)
% Solve (generalised) product matrix eigenvalue problem.

if nargin<2
	Bs = {};
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
    [B idx]          = sort(devs(1,:));
    DD(i)            = sum(evals(idx(1:N)))/N;
    devs(:,idx(1:N)) = [];
    devs(idx(1:N),:) = [];
    evals(idx(1:N))  = [];
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
    [B idx]          = sort(devs(1,:));
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
	
  varargout{1} = XX;
  varargout{2} = diag(DD);
end

end
