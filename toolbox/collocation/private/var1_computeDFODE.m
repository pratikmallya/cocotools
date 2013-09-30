function [opts coll] = var1_computeDFODE(opts, coll, x0, p0)
%Compute variational system at (X0,P0).

%% initialisations
%  map base points to collocation points
xx = reshape(coll.W * x0, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p0, [1 coll.xshape(2)]);

%  extract T from x
T  = x0(coll.tintidx);

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
dfode = reshape(dfode(coll.var1.midx), [prod(coll.var1.dxshape) 1]);
dfode = sparse(coll.var1.dxrows, coll.var1.dxcols, dfode);

%  compute linearisation with respect to x ( = dfode * W )
coll.var1.dfode = dfode * coll.var1.W;
