function [sol data] = alg_read_solution(oid, run, lab)

tbid         = coco_get_id(oid, 'alg');
[data chart] = coco_read_solution(tbid, run, lab);
sol.x = chart.x(data.x_idx);
sol.p = chart.x(data.p_idx);
sol.u = [sol.x; sol.p];

end