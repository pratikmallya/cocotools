function [data_ptr g] = func_LFUNC(opts, data_ptr, xp) %#ok<INUSL>
%FUNC_LFUNC  Evaluate linear functional A*x=b.

data = data_ptr.data;

x    = reshape(xp, data.xshape);
g    = sum(data.A.*x, 2)-data.b;
