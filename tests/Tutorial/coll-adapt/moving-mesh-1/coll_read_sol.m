function [t x] = coll_read_sol(oid, run, lab)

tbid = coco_get_id(oid, 'coll');
[data chart] = coco_read_solution(tbid, run, lab);
maps         = data.maps;
mesh         = data.mesh;

t = mesh.tbp * chart.x(maps.Tidx);
x = chart.x(maps.x_idx(1:end-1));
x = reshape(x,[maps.dim,maps.NTST*(maps.NCOL+1)]);

end