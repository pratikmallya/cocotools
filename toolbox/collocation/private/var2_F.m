function [coll f] = var2_F(opts, coll, xp) %#ok<INUSL>
%Evaluate extended collocation system at (x,M,p).

%% initialisations
% extract x and p from xp
x = xp(coll.x_idx,1);
p = xp(coll.p_idx,1);

%% evaluate collocation system and variational equation
[coll f1] = var2_coll_F(coll, x, p);
[coll f2] = var2_var_F (coll, x, p);

f = [f1 ; f2];
end

function [coll f] = var2_coll_F(coll, x, p)
%Evaluate collocation system COLL_F at (X,P).

%  map base points to collocation points
xx = reshape(coll.W  * x, coll.xshape);

%  map base points to derivative at collocation points
xp = reshape(coll.Wp * x, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T from x
T  = x(coll.tintidx);

%% evaluate collocation condition
%  preallocate array for vector fields
fode = zeros(coll.xshape);

%  evaluate each vector field
for rhsnum=1:length(coll.rhss)
	fode(:, coll.rhss(rhsnum).xcolidx) = ...
		coll.rhss(rhsnum).fhan(xx(:,coll.rhss(rhsnum).xcolidx), ...
		pp(:,coll.rhss(rhsnum).xcolidx));
end

%  expand T and ka to fit size of xx
T    = T(coll.tintxidx);
ka   = coll.ka(coll.kaxidx);

%  evaluate collocation condition
%  and reshape into a single column vector
fode = T .* ka .* fode - xp;
fode = reshape(fode, [prod(coll.xshape) 1]);

%% evaluate continuity condition
%  for all inner points
fcont = coll.Phi * x;

%% combine all conditions
%  into one large vector
%  Note: this will become re-ordered in the future to reduce band width.
f = [ fode ; fcont ];
end

function [coll f] = var2_var_F(coll, x, p)

%  map base points to collocation points
xx = reshape(coll.W   * x, coll.xshape);
M  = reshape(coll.MW  * x, [prod(coll.mshape) 1]);

%  map base points to derivative at collocation points
Mp = reshape(coll.MWp * x, [prod(coll.mshape) 1]);

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
%  and convert into sparse matrix
dfode = T .* ka .* dfode;
dfode = reshape(dfode(coll.midx), [prod(coll.dmshape) 1]);
dfode = sparse(coll.dmrows, coll.dmcols, dfode);

%% evaluate variational system
%  and reshape into a single column vector
fvar = dfode*M - Mp;

%% evaluate continuity condition
%  for all inner points
fcont = coll.MPhi * x;

%% evaluate boundary condition
%  create sparse matrix with segments of M
M0idx = reshape(coll.m0idx, [prod(coll.m0shape) 1]);
M1idx = reshape(coll.m1idx, [prod(coll.m1shape) 1]);

M0  = x(M0idx);
M1  = x(M1idx);

iw  = coll.iw(coll.kamidx);
Mal = iw.*M;
Mal = sparse(coll.mrows, coll.mcols, Mal(coll.midx));
MM  = Mal*M;

fbc = M0 + M1 + MM - coll.mbceye;

%% combine all conditions
%  into one large vector
%  Note: this will become re-ordered in the future to reduce band width.
f = [ fvar ; fcont ; fbc ];

end
