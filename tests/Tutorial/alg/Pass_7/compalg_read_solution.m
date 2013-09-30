function [sol data] = compalg_read_solution(oid, run, lab)

tbid = coco_get_id(oid, 'compalg');
data = coco_read_solution(tbid, run, lab);

sol(data.neqs) = struct('x', [], 'p', []);
for i=1:data.neqs
  algoid = coco_get_id(tbid, sprintf('eqn%d', i));
  algsol = alg_read_solution(algoid, run, lab);
  sol(i).x = algsol.x;
  sol(i).p = algsol.p;
end

end