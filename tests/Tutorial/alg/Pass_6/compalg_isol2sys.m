% varargin = {@f [(@dfdx | '[]) [(@dfdp | '[])]] x0 [pnames] p0 }
%!compalg_isol2sol
function prob = compalg_isol2sys(prob, oid, varargin)

tbid = coco_get_id(oid, 'compalg');
str  = coco_stream(varargin{:});
fhans = str.get('cell');
data.neqs = numel(fhans);
dfdxhans = cell(1, data.neqs);
dfdphans = cell(1, data.neqs);
if is_empty_or_func(str.peek('cell'))
  dfdxhans = str.get('cell');
  if is_empty_or_func(str.peek('cell'))
    dfdphans = str.get('cell');
  end
end
x0 = str.get('cell');
data.pnames = {};
if iscellstr(str.peek('cell'))
  data.pnames = str.get('cell');
end
p0 = str.get;

compalg_arg_check(tbid, data, dfdxhans, dfdphans, x0, p0);
for i=1:data.neqs
  toid = coco_get_id(tbid, sprintf('eqn%d', i));
  prob = alg_isol2eqn(prob, toid, fhans{i}, dfdxhans{i}, ...
    dfdphans{i}, x0{i}, p0);
end
prob = compalg_close_sys(prob, tbid, data);

end
%!end_compalg_isol2sol
function flag = is_empty_or_func(x)

flag = all(cellfun('isempty', x) | ...
  cellfun('isclass', x, 'function_handle'));

end
%!end_is_empty