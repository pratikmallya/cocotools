function [coll J] = var2_DFDP(coll, x, p)
%Compute parameter derivatives DCOLL_F/DP at (X,P).

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of derivative
% [opts J] = coco_num_DFDP(opts, opts.func.F, x, p, pars);

%% initialisations
%  map base points to collocation points
xx = reshape(coll.W * x, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T from x
T  = x(coll.tintidx);

%  expand T and ka to fit size of xx
T    = T(coll.tintxidx);
ka   = coll.ka(coll.kaxidx);

%% compute derivative of collocation condition
%  preallocate array for derivatives
dfode = zeros([coll.xshape length(p)]);

%  compute derivatives of each vector field
%  Note: we should get rid of the loop over j!
for j=1:length(p)
	for rhsnum=1:length(coll.rhss)
		% Note: this needs to be modified to perform tests as in
		% exacont/private/func_DFDP
		dfode(:, coll.rhss(rhsnum).xcolidx, j) = ...
			coco_num_DFDPv(coll.rhss(rhsnum).fhan, xx(:,coll.rhss(rhsnum).xcolidx), ...
			pp(:,coll.rhss(rhsnum).xcolidx), j);
	end
	%  evaluate derivative of collocation condition
	dfode(:,:,j) = T .* ka .* dfode(:,:,j);
end
%  reshape into a matrix with length(pars) columns
dfode = reshape(dfode, [prod(coll.xshape) length(p)]);

%% derivative of continuity condition
dfcont = sparse( size(coll.Phi,1), length(p) );

%% combine derivatives of all conditions
%  into one large vector
%  Note: this will become re-ordered in the future to reduce band width.
J = [ dfode ; dfcont ];
