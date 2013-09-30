% varargin = { {alg} [pnames | 'end-alg'] }
% alg      = { @f [(@dfdx |'[]') [(@dfdp |'[]')]] x0 p0 }
%!compalg_isol2sol
function prob = compalg_isol2sys(prob, oid, varargin)

tbid = coco_get_id(oid, 'compalg');
str  = coco_stream(varargin{:});
data.neqs = 0;
while isa(str.peek, 'function_handle')
  data.neqs = data.neqs+1;
  toid      = coco_get_id(tbid, sprintf('eqn%d', data.neqs));
  prob      = alg_isol2eqn(prob, toid, str);
end
data.pnames = {};
if strcmpi(str.peek, 'end-alg')
  str.skip;
elseif iscellstr(str.peek('cell'))
  data.pnames = str.get('cell');
end

compalg_arg_check(prob, tbid, data);
prob = compalg_close_sys(prob, tbid, data);

end %!end_compalg_isol2sol