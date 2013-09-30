% varargin = { @f [@dfdx [@dfdp]] t0 x0 [pnames] p0 }
%!coll_isol2seg
function prob = coll_isol2seg(prob, oid, varargin)

tbid = coco_get_id(oid, 'coll');
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

coll_arg_check(tbid, data, t0, x0, p0);
data = coll_get_settings(prob, tbid, data);
data = coll_init_data(data, t0, x0, p0);
sol  = coll_init_sol(data, t0, x0, p0);
prob = coll_construct_seg(prob, tbid, data, sol);

end %!end_coll_isol2seg

function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end