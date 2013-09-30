function evm = multipliers(bd, run)

labs = coco_bd_labs(bd, 'all');
pars = coco_bd_col(bd, 'PAR(1)');
idx  = ~cellfun('isempty', coco_bd_col(bd, 'LAB') );
pars = pars(idx);
evm  = [];

for j=1:numel(labs)
	lab=labs(j);
	par=pars(j);
  sol  = coco_read_solution('coll', run, lab);
	data = sol.sol;
	
	if isfield(data, 'M0')
		E  = eye(size(data.M0,1), size(data.M0,3));
		M  = E;
		k  = size(data.M0, 2);

		for i=1:k-1
			M = squeeze(data.M1(:,i,:)) * (squeeze(data.M0(:,i,:))\M);
		end

		evals = eig(M * squeeze(data.M1(:,k,:)), squeeze(data.M0(:,k,:)));

		for i=1:k
			M0{i} = squeeze(data.M0(:,k-i+1,:)); %#ok<AGROW>
			M1{i} = squeeze(data.M1(:,k-i+1,:)); %#ok<AGROW>
		end
		
		evals2 = peig(M1,M0);
		
		[d idx1] = sort(abs(evals-1));
		[d idx2] = sort(abs(evals2-1));
		
		evm = [evm [lab;par;evals(idx1);evals2(idx2)]]; %#ok<AGROW>
	end
end

if nargout<1 && ~isempty(evm)
	evm = evm';
	fprintf(' %12s %3s %12s %12s %12s %12s %12s %12s\n', 'PAR', 'LAB', ...
		'mu_1', 'mu_2', 'mu_1', 'mu_2', 'rel_diff1', 'rel_diff2');
	for i=1:size(evm,1)
		fprintf(' % 12.4e % 3d % 12.4e % 12.4e % 12.4e % 12.4e % 12.4e % 12.4e\n', ...
			evm(i,2), evm(i,1), evm(i,3), evm(i,4), evm(i,5), evm(i,6), ...
			abs(evm(i,3)-evm(i,5))/(0+abs(evm(i,5))), ...
			abs(evm(i,4)-evm(i,6))/(0+abs(evm(i,6))));
	end
end

end

function [DD] = peig(As, Bs)

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

end