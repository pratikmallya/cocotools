function [sol data] = compalg_read_solution(oid, run, lab)

tbid = coco_get_id(oid, 'compalg');
data = coco_read_solution(tbid, run, lab);

sol = struct('x', [], 'p', []);
for i=1:data.neqs
  soid     = coco_get_id(tbid, sprintf('eqn%d', i));
  algsol   = alg_read_solution(soid, run, lab);
  sol.x{i} = algsol.x;
end
sol.p = algsol.p;

end