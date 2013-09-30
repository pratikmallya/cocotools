% varargin = { @f [@dfdx [@dfdp]] modes events resets t0cell x0cell [pnames] p0 }
%!hspo_isol2sol
function prob = hspo_isol2segs(prob, oid, varargin)

tbid = coco_get_id(oid, 'hspo');
str  = coco_stream(varargin{:});
fhan = str.get;
dfdxhan = cell(1,3);
dfdphan = cell(1,3);
if is_empty_or_func(str.peek)
  dfdxhan = str.get;
  if is_empty_or_func(str.peek)
    dfdphan = str.get;
  end
end
modes  = str.get('cell');
events = str.get('cell');
resets = str.get('cell');
t0     = str.get('cell');
x0     = str.get('cell');
pnames = {};
if iscellstr(str.peek('cell'))
  pnames = str.get('cell');
end
p0 = str.get;

hspo_arg_check(tbid, fhan, dfdxhan, dfdphan, ...
  modes, events, resets, t0, x0, p0, pnames);
coll = {};
for i=1:numel(modes)
  coll = [coll, {...
    coll_func(fhan{1},    modes{i}), ...
    coll_func(dfdxhan{1}, modes{i}), ...
    coll_func(dfdphan{1}, modes{i}), ...
    t0{i}, x0{i}, p0}];
end
hspo_bc_data = hspo_get_settings(prob, tbid);
hspo_bc_data = hspo_init_data(hspo_bc_data, fhan, dfdxhan, dfdphan, ...
  modes, events, resets, x0, p0);
prob = msbvp_isol2segs(prob, oid, coll{:}, pnames, ...
  @hspo_bc, @hspo_bc_DFDX, hspo_bc_data);
if hspo_bc_data.hspo.bifus
  prob = hspo_add_bifus(prob, oid, tbid, hspo_bc_data);
end

end %!end_hspo_isol2sol

function fhan = coll_func(fhan, mode)

if isa(fhan, 'function_handle')
  fhan = @(x,p) fhan(x,p,mode);
end

end

function flag = is_empty_or_func(x)

flag = isa(x, 'function_handle') || ...
  all(cellfun('isempty', x) | cellfun('isclass', x, 'function_handle'));

end