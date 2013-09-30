function [sol data] = msbvp_read_solution(oid, run, lab)

tbid = coco_get_id(oid, 'msbvp');
data = coco_read_solution(tbid, run, lab);

sol = cell(1, data.nsegs);
for i=1:data.nsegs
  segoid = coco_get_id(tbid, sprintf('seg%d', i));
  sol{i} = coll_read_solution(segoid, run, lab);
end

end