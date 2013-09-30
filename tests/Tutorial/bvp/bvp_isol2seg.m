% varargin = { coll @f [@dfdx]}
% coll = { @f [@dfdx [@dfdp]] t0 x0 [pnames] p0 }
%!bvp_isol2sol
function prob = bvp_isol2seg(prob, oid, varargin)

tbid   = coco_get_id(oid, 'bvp');
segoid = coco_get_id(tbid, 'seg');
str    = coco_stream(varargin{:});
prob   = coll_isol2seg(prob, segoid, str);
data.fhan = str.get;
data.dfdxhan = [];
if is_empty_or_func(str.peek)
  data.dfdxhan = str.get;
end

data = bvp_init_data(prob, tbid, data);
bvp_arg_check(prob, tbid, data);
prob = bvp_close_seg(prob, tbid, data);

end

function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end
%!end_bvp_isol2sol