function [sol data] = po_read_solution(oid, run, lab)

tbid = coco_get_id(oid, 'po');
data = coco_read_solution(tbid, run, lab);

segoid = coco_get_id(tbid, 'seg');
sol    = coll_read_solution(segoid, run, lab);

end