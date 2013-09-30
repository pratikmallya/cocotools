function prob = alg_sol2eqn(prob, oid, varargin)

tbid = coco_get_id(oid, 'alg');
str  = coco_stream(varargin{:});
run  = str.get;
if ischar(str.peek)
  soid = str.get;
else
  soid = oid;
end
lab = str.get;

[sol data] = alg_read_solution(soid, run, lab);
data       = alg_get_settings(prob, tbid, data);
prob       = alg_construct_eqn(prob, tbid, data, sol);

end