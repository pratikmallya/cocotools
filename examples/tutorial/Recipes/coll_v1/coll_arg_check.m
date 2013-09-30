function coll_arg_check(tbid, data, t0, x0, p0)
% 7.2.3  An embeddable generalized constructor
%
% COLL_ARG_CHECK(TBID, DATA, T0, X0, P0)
%
% Check sanity of arguments passed to coll_isol2seg.
%
%   See also: coll_v1

assert(isa(data.fhan, 'function_handle'), ...
  '%s: input for ''f'' is not a function handle', tbid);
assert(isnumeric(t0), '%s: input for ''t0'' is not numeric', tbid);
assert(isnumeric(x0), '%s: input for ''x0'' is not numeric', tbid);
assert(isnumeric(p0), '%s: input for ''p0'' is not numeric', tbid);
assert(ndims(t0)==2 && min(size(t0))==1, ...
  '%s: input for ''t0'' is not a vector', tbid);
assert(ndims(x0)==2, ...
  '%s: input for ''x0'' is not an array of vectors', tbid);
assert(size(x0, 1)==numel(t0), ...
  '%s: dimensions of ''t0'' and ''x0'' do not match', tbid);
assert(numel(p0)==numel(data.pnames) || isempty(data.pnames), ...
  '%s: incompatible number of elements for ''p0'' and ''pnames''', ...
  tbid);

end