function [opts x] = coll_linsolve(opts, A, b)
%Default solver for linearised equations.

if nargout<2
	error('%s: too few output arguments', mfilename);
end

x = A\b;
