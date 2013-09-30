function alg_arg_check(tbid, data, x0, p0)

assert(isa(data.fhan, 'function_handle'), ...
  '%s: input for ''f'' is not a function handle', tbid);
assert(isnumeric(x0), '%s: input for ''x0'' is not numeric', tbid);
assert(isnumeric(p0), '%s: input for ''p0'' is not numeric', tbid);
assert(numel(p0)==numel(data.pnames) || isempty(data.pnames), ...
  '%s: incompatible number of elements for ''p0'' and ''pnames''', ...
  tbid);

end