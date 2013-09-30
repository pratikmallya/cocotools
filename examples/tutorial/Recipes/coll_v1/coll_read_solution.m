function [sol data] = coll_read_solution(oid, run, lab)
% 7.2.3  An embeddable generalized constructor
%
% [SOL DATA] = COLL_READ_SOLUTION(OID, RUN, LAB)
%
% Read collocation toolbox solution structure and toolbox data from disk.
%
%   See also: coll_v1

tbid         = coco_get_id(oid, 'coll');
[data chart] = coco_read_solution(tbid, run, lab);

sol.t = data.tbp(data.tbp_idx)*chart.x(data.T_idx);
xbp   = reshape(chart.x(data.xbp_idx), data.xbp_shp)';
sol.x = xbp(data.tbp_idx,:);
sol.p = chart.x(data.p_idx);

end