function coll_check(tbid, data, t0, x0, p0, dx0)

assert(isa(data.fhan, 'function_handle'), ...
  '%s: input for ''f'' is not a function handle', tbid);
assert(isempty(data.dfdxhan) || isa(data.dfdxhan, 'function_handle'), ...
  '%s: input for ''dfdx'' is not a function handle', tbid);
assert(isempty(data.dfdphan) || isa(data.dfdphan, 'function_handle'), ...
  '%s: input for ''dfdp'' is not a function handle', tbid);

assert(~isempty(t0), '%s: input for ''t0'' is empty', tbid);
assert(ndims(t0)==2 && min(size(t0))==1, ...
  '%s: input for ''t0'' is not a vector', tbid);
assert(isnumeric(t0), '%s: input for ''t0'' is not numeric', tbid);

assert(~isempty(x0), '%s: input for ''x0'' is empty', tbid);
assert(ndims(x0)==2, ...
  '%s: input for ''x0'' is not an array of vectors', tbid);
assert(isnumeric(x0), '%s: input for ''x0'' is not numeric', tbid);
assert(size(x0,1)==numel(t0), ...
  '%s: dimensions of ''t0'' and ''x0'' do not match', tbid);

assert(ndims(dx0)==2, ...
  '%s: input for ''tangent'' is not an array of vectors', tbid);
assert(isnumeric(dx0), '%s: input for ''tangent'' is not numeric', tbid);
assert(isempty(dx0) || all(size(dx0)==size(x0)), ...
  '%s: dimensions of ''x0'' and ''tangent'' do not match', tbid);

assert(isnumeric(p0), '%s: input for ''p0'' is not numeric', tbid);

coll  = data.coll;

assert(coll.NTSTMN<=coll.NTST && coll.NTST<=coll.NTSTMX, ...
  '%s: NTST out of range [range=NTSTMN<=NTST<=NTSTMX]');

assert(ischar(coll.mesh) && ...
  any(strcmpi(coll.mesh, {'uniform' 'frozen' 'moving' 'co-moving'})), ...
  '%s: unknown mesh type [known types=uniform|frozen|moving|co-moving]');

end
