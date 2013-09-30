function prob = bvp_sol2seg(prob, oid, varargin)

ttbid = coco_get_id(oid, 'bvp');
str  = coco_stream(varargin{:});
run  = str.get;
if ischar(str.peek)
  stbid = coco_get_id(str.get, 'bvp');
else
  stbid = ttbid;
end
lab = str.get;

data = coco_read_solution(stbid, run, lab);
toid = coco_get_id(ttbid, 'seg');
soid = coco_get_id(stbid, 'seg');
prob = coll_sol2seg(prob, toid, run, soid, lab);
data = bvp_init_data(prob, ttbid, data);
prob = bvp_close_seg(prob, ttbid, data);

end