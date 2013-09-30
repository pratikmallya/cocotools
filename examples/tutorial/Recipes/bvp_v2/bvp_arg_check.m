function bvp_arg_check(prob, tbid, data)

assert(isa(data.fhan, 'function_handle'), ...
  '%s: input for ''f'' is not a function handle', tbid);

end