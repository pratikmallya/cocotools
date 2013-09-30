function alg_arg_check(data, x0, p0)

assert(isa(data.fhan, 'function_handle'), ...
  'alg: input for ''f'' is not a function handle');
assert(isnumeric(x0), 'alg: input for ''x0'' is not numeric');
assert(isnumeric(p0), 'alg: input for ''p0'' is not numeric');
assert(numel(p0)==numel(data.pnames) || isempty(data.pnames), ...
  'alg: incompatible number of elements for ''p0'' and ''pnames''');

end