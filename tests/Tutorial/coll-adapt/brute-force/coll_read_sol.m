function [t x data] = coll_read_sol(oid, run, lab)

tbid = coco_get_id(oid, 'coll');
[data chart] = coco_read_solution(tbid, run, lab);

t = data.tbp * chart.x(data.Tidx);
x = chart.x(data.x_idx(1:end-1));
x = reshape(x,[data.dim,data.coll.NTST*(data.coll.NCOL+1)]);

end