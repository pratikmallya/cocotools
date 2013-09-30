function prob = msbvp_sol2segs(prob, oid, varargin)

ttbid = coco_get_id(oid, 'msbvp');
str = coco_stream(varargin{:});
run = str.get;
if ischar(str.peek)
  stbid = coco_get_id(str.get, 'msbvp');
else
  stbid = ttbid;
end
lab = str.get;

data = coco_read_solution(ttbid, run, lab);
for i=1:data.nsegs
  toid = coco_get_id(ttbid, sprintf('seg%d', i));
  soid = coco_get_id(stbid, sprintf('seg%d', i));
  prob = coll_sol2seg(prob, toid, run, soid, lab);
end
data = msbvp_init_data(prob, ttbid, data);
prob = msbvp_close_segs(prob, ttbid, data);

end