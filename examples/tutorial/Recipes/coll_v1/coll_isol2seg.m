function prob = coll_isol2seg(prob, oid, varargin)
% 7.2.3  An embeddable generalized constructor
%
% PROB = COLL_ISOL2SEG(PROB, OID, VARARGIN)
% VARARGIN = { @F [@DFDX [@DFDP]] T0 X0 [PNAMES] P0 }
%
% Construct and initialize collocation problem from known solution guess.
%
%   See also: coll_v1

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
data = coll_init_data(data, x0, p0);
sol  = coll_init_sol(data, t0, x0, p0);
prob = coll_construct_seg(prob, tbid, data, sol);

end

function flag = is_empty_or_func(x)
  flag = isempty(x) || isa(x, 'function_handle');
end
