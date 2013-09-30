% varargin = { {coll} (pname | pnames | 'end-coll') @fbc [@dfbcdx] [data [@update]] }
% coll = { @f [@dfdx [@dfdp]] t0 x0 p0 }
%!msbvp_isol2sol
function prob = msbvp_isol2segs(prob, oid, varargin)

tbid = coco_get_id(oid, 'msbvp');
str  = coco_stream(varargin{:});
data.nsegs = 0;
while isa(str.peek, 'function_handle')
  data.nsegs = data.nsegs+1;
  segoid = coco_get_id(tbid, sprintf('seg%d', data.nsegs));
  prob   = coll_isol2seg(prob, segoid, str);
end
data.pnames = {};
if strcmpi(str.peek, 'end-coll')
  str.skip;
else
  data.pnames = str.get('cell');
end
data.fbchan = str.get;
data.dfbcdxhan = [];
if is_empty_or_func(str.peek)
  data.dfbcdxhan = str.get;
end
data.bc_data   = struct();
data.bc_update = [];
if isstruct(str.peek)
  data.bc_data = str.get;  
  if is_empty_or_func(str.peek)
    data.bc_update = str.get;
  end
end

msbvp_arg_check(prob, tbid, data);
data = msbvp_init_data(prob, tbid, data);
prob = msbvp_close_segs(prob, tbid, data);

end

function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end
%!end_msbvp_isol2sol