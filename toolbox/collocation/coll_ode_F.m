function f = coll_ode_F(coll, segnum, x, p)
%Evaluate segmented RHS.

%% evaluate collocation condition
%  preallocate array for vector fields
f = zeros(size(x));

%  evaluate each vector field
for i = 1:numel(segnum)
	f(:,i) = coll.segs(i).fhan(x(:,i), p(:,i));
end
