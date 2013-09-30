function [t x] = coll_read_sol(prefix, run, lab)

fid  = coco_get_id(prefix, 'coll_save');
[data sol] = coco_read_solution(fid, run, lab);

x = sol.x(data.xidx);
t = data.tbp * x(data.Tidx);

x = x(data.x_idx(1:end-1));
x = reshape(x,[data.dim,data.NTST*(data.NCOL+1)]);

end