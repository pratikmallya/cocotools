function [t x] = calcvar_read_sol(prefix, run, lab)

fid  = coco_get_id(prefix, 'calcvar_save');
[data sol] = coco_read_solution(fid, run, lab);

t = data.tbp;

x = sol.x(data.x_idx);
x = reshape(x,[1,data.NTST*(data.NCOL+1)]);

end