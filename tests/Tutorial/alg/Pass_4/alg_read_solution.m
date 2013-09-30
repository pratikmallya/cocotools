function [sol data] = alg_read_solution(run, lab)

[data chart] = coco_read_solution('alg', run, lab);
sol.x = chart.x(data.x_idx);
sol.p = chart.x(data.p_idx);
sol.u = [sol.x; sol.p];

end