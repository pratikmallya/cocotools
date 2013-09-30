function prob = coll_sol2seg(prob, oid, varargin)

tbid = coco_get_id(oid, 'coll');
str  = coco_stream(varargin{:});
run  = str.get;
if ischar(str.peek)
  soid = str.get;
else
  soid = oid;
end
lab = str.get;

[sol data] = coll_read_solution(soid, run, lab);
data       = coll_get_settings(prob, tbid, data);
data       = coll_init_data(data, sol.t, sol.x, sol.p);
sol        = coll_init_sol(data, sol.t, sol.x, sol.p);
prob       = coll_construct_seg(prob, tbid, data, sol);

end