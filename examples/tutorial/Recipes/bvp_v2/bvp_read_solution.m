function [sol data] = bvp_read_solution(oid, run, lab)

tbid = coco_get_id(oid, 'bvp');
data = coco_read_solution(tbid, run, lab);

segoid = coco_get_id(tbid, 'seg');
sol    = coll_read_solution(segoid, run, lab);

end