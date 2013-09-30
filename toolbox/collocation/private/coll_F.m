function [coll f] = coll_F(opts, coll, xp) %#ok<INUSL>
%Evaluate collocation system COLL_F at (X,P).

%% initialisations
% extract x and p from xp
x = xp(coll.x_idx,1);
p = xp(coll.p_idx,1);

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
