function [data_ptr J] = func_DLFUNCDX(opts, data_ptr, xp)  %#ok<INUSD,INUSL>
%FUNC_DLFUNCDX  Compute linearisation of linear functional A*x=b.

data = data_ptr.data;

J    = sparse(data.fidx, data.xidx, data.A, ...
    data.xshape(1), prod(data.xshape));
