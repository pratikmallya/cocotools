function [x p] = alg_read_solution(run, lab)

[data chart] = coco_read_solution('alg', run, lab);
x = chart.x(data.x_idx);
p = chart.x(data.p_idx);

end