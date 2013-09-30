function [opts argnum] = coll_restart(opts, prefix, rrun, rlab)

fid        = coco_get_id(prefix, 'coll_save');
[data sol] = coco_read_solution(fid, rrun, rlab);

x  = sol.x(data.xidx);
x0 = x(data.x_idx);
p0 = x(data.p_idx);

opts = coll_create(opts, data, x0, p0, []);

argnum = 3;

end