% varargin = { @f [(@dfdx |'[]') [(@dfdp |'[]')]] x0 [pnames] p0 }
%!alg_isol2sol
function prob = alg_isol2eqn(varargin)

str = coco_stream(varargin{:});
data.fhan = str.get;
data.dfdxhan = [];
data.dfdphan = [];
if is_empty_or_func(str.peek)
  data.dfdxhan = str.get;
  if is_empty_or_func(str.peek)
    data.dfdphan = str.get;
  end
end
x0 = str.get;
data.pnames = {};
if iscellstr(str.peek('cell'))
  data.pnames = str.get('cell');
end
p0 = str.get;

alg_arg_check(data, x0, p0);
data  = alg_init_data(data, x0, p0);
sol.u = [x0(:); p0(:)];
prob  = alg_construct_eqn(data, sol);

end
%!end_alg_isol2sol
function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end
%!end_is_empty