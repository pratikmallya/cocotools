function [sol data] = coll_read_solution(oid, run, lab)

tbid         = coco_get_id(oid, 'coll');
[data chart] = coco_read_solution(tbid, run, lab);
maps         = data.maps;
mesh         = data.mesh;

sol.t = mesh.tbp(maps.tbp_idx)*chart.x(maps.T_idx);
xbp   = reshape(chart.x(maps.xbp_idx), maps.xbp_shp)';
sol.x = xbp(maps.tbp_idx,:);
sol.p = chart.x(maps.p_idx);

end