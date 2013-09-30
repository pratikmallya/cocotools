function prob = dft_isol2orb(prob, oid, varargin)

tbid = coco_get_id(oid, 'dft');
str  = coco_stream(varargin{:});
data.fhan = str.get;
data.dfdxhan  = [];
data.dfdphan  = [];
if is_empty_or_func(str.peek)
  data.dfdxhan = str.get;
  if is_empty_or_func(str.peek)
    data.dfdphan = str.get;
  end
end
t0 = str.get;
x0 = str.get;
data.pnames = {};
if iscellstr(str.peek('cell'))
  data.pnames = str.get('cell');
end
p0 = str.get;
if strcmpi(str.peek, 'end-dft')
  str.skip;
end

dft_arg_check(tbid, data, t0, x0, p0);
data = dft_get_settings(prob, tbid, data);
sol  = dft_init_sol(data, t0, x0, p0);
data = dft_init_data(data, sol);
prob = dft_construct_orb(prob, tbid, data, sol);

end

function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end