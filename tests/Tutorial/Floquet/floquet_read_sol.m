function [t x] = floquet_read_sol(prefix, run, lab)

fid  = coco_get_id(prefix, 'floquet_save');
[data_ptr sol] = coco_read_solution(fid, run, lab);
data = data_ptr.data;

x = sol.x(data.xidx);
t = data.tbp * x(data.Tidx);

x = x(data.x_idx(1:end-1));
x = reshape(x,[data.dim,data.NTST*(data.NCOL+1)]);

end