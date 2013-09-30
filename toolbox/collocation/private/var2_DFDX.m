function [coll J] = var2_DFDX(opts, coll, xp) %#ok<INUSL>
%Compute linearisation of extended collocation system at (x,M,p).

%% initialisations
% extract x and p from xp
x = xp(coll.x_idx,1);
p = xp(coll.p_idx,1);

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of linearisation and remove the irrelevant parts
% [opts JJ] = coco_num_DFDX(opts, @var2_F, xp); %#ok<NASGU>
% [m n] = size(J1);
% JJ1 = sparse(JJ(1:m,:));
% JJ2 = [sparse(size(J2,1), m) sparse(JJ(m+1:end,m+1:end-length(p)))];
% max(max(abs(J1-JJ1)))
% max(max(abs(J2-JJ2)))

%% compute linearisation of collocation system and variational equation
[coll J1 dfode] = var2_coll_DFDX(coll, x, p);
[coll J2]       = var2_var_DFDX (coll, dfode, x, p);

J = [J1 ; J2 sparse(size(J2,1), length(p))];
end

function [coll J dfode] = var2_coll_DFDX(coll, x, p)
%Compute linearisation COLL_DFDX of collocation system at (X,P).

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%  map base points to collocation points
xx = reshape(coll.W * x, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T from x
T  = x(coll.tintidx);

%% compute linearisation of collocation condition wrt. x
%  preallocate array for linearisation of vector fields
dfode = zeros(coll.dxshape);

%  compute linearisation of each vector field
for rhsnum=1:length(coll.rhss)
	% Note: this needs to be modified to perform tests as in
	% exacont/private/func_DFDX
	dfode(:, coll.rhss(rhsnum).dxcolidx) = ...
		coco_num_DFDXv(coll.rhss(rhsnum).fhan, ...
			xx(:,coll.rhss(rhsnum).xcolidx), ...
			pp(:,coll.rhss(rhsnum).xcolidx));
end

%  expand T and ka to fit size of d(xx)
T     = T(coll.tintdxidx);
ka    = coll.ka(coll.kadxidx);

%  compute linearisation of T .* ka .* fode with respect to xx
dfode = T .* ka .* dfode;

%  convert into sparse matrix
dfodes = reshape(dfode, [prod(coll.dxshape) 1]);
dfodes = sparse(coll.dxrows, coll.dxcols, dfodes);

%  compute linearisation with respect to x ( = dfodes * W - Wp [chain rule])
%  and split resulting sparse matrix
dfodes = dfodes * coll.W - coll.Wp;
[r c v] = find(dfodes);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

%% compute linearisation of collocation condition wrt. T
%  preallocate array for derivative with respect to T
fode = zeros(coll.xshape);

%  evaluate each vector field
for rhsnum=1:length(coll.rhss)
	fode(:, coll.rhss(rhsnum).xcolidx) = ...
		coll.rhss(rhsnum).fhan(xx(:,coll.rhss(rhsnum).xcolidx), ...
		pp(:,coll.rhss(rhsnum).xcolidx));
end

%  expand ka to fit size of xx
ka   = coll.ka(coll.kaxidx);

%  compute linearisation and append data to rows, cols and vals
fode = ka .* fode;
r    = (1:prod(coll.xshape))';
c    = coll.tintidx(coll.tintxidx);
c    = reshape(c, [prod(coll.xshape) 1]);
fode = reshape(fode, [prod(coll.xshape) 1]);

rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; fode];
off  = off + prod(coll.xshape);

%% linearisation of continuity condition
[r c v] = find(coll.Phi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(coll.Phi,1);

%% Create sparse matrix of linearisation
%  Note: this will become re-ordered in the future to reduce band width.
J1 = sparse(rows, cols, vals, off, length(x));

% for timing tests (no improvement):
% J1 = sparse(rows, cols, vals, coll.fullsize, coll.fullsize, numel(vals));

%% add derivatives wrt parameters
[coll J2] = var2_DFDP(coll, x, p);

%% combine the two Jacobians
J = sparse([J1 J2]);
end

function [coll J] = var2_var_DFDX(coll, dfode, x, p) %#ok<INUSD>
%Compute linearisation of variational equation at (M,beta).

%  map base points to collocation points
M  = reshape(coll.MW * x, [prod(coll.mshape) 1]);

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%% compute linearisation of variational system wrt. (x,p)
dfode = reshape(dfode(coll.midx), [prod(coll.dmshape) 1]);
dfode = sparse(coll.dmrows, coll.dmcols, dfode);
dfode = dfode*coll.MW  - coll.MWp;
[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(coll.MWp,1);

%% linearisation of continuity condition
[r c v] = find(coll.MPhi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(coll.MPhi,1);

%% linearisation of boundary condition
M0idx = reshape(coll.m0idx, [prod(coll.m0shape) 1]);
M1idx = reshape(coll.m1idx, [prod(coll.m1shape) 1]);

rows = [rows ; off + (1:length(M0idx))' ; off + (1:length(M1idx))'];
cols = [cols ; M0idx ; M1idx];
vals = [vals ; ones(length(M0idx)+length(M1idx), 1) ];

iw   = coll.iw(coll.kamidx);
WMal = coll.MW'*(iw.*M);
WMal = WMal(coll.dmidx);
WM   = sparse(coll.dmrows2, coll.dmcols2, WMal);
WMal = sparse(coll.dmrows1, coll.dmcols1, WMal);

[r c v] = find(WMal + WM);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
%off  = off + size(Jbc,1);

%% Create sparse matrix of linearisation
%  Note: this will become re-ordered in the future to reduce band width.
J = sparse(rows, cols, vals);

% for timing tests (no improvement):
% J = sparse(rows, cols, vals, coll.fullsize, coll.fullsize, numel(vals));
end
