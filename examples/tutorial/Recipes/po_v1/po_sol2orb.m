function prob = po_sol2orb(prob, oid, varargin)

ttbid = coco_get_id(oid, 'po');
str   = coco_stream(varargin{:});
run   = str.get;
if ischar(str.peek)
  stbid = coco_get_id(str.get, 'po');
else
  stbid = ttbid;
end
lab = str.get;

toid = coco_get_id(ttbid, 'seg');
soid = coco_get_id(stbid, 'seg');
prob = coll_sol2seg(prob, toid, run, soid, lab);
data = coco_read_solution(stbid, run, lab);
data = po_init_data(prob, ttbid, data);
prob = po_close_orb(prob, ttbid, data);

end