function prob = po_mult_add(prob, segoid)
data = po_mult_init_data(prob, segoid);
tbid = coco_get_id(segoid, 'mult');
data.pnames = coco_get_id(tbid, data.pnames);
data.mnames = coco_get_id(tbid, 'multipliers');
prob = coco_add_func(prob, tbid, @po_eigs, data, 'regular', data.pnames);
prob = coco_add_slot(prob, tbid, @po_eigs_bddat, data, 'bddat');
end

function data = po_mult_init_data(prob, segoid)
data.tbid   = coco_get_id(segoid, 'var');
fdata       = coco_get_func_data(prob, data.tbid, 'data');
data.pnames = arrayfun(@(i) sprintf('|m%d|', i), ...
  1:fdata.dim, 'UniformOutput', false);
end

function [data y] = po_eigs(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid, 'data');
M0    = fdata.M(fdata.M0_idx,:);
M1    = fdata.M(fdata.M1_idx,:);
y     = abs(eig(M1,M0));

end

function [data res] = po_eigs_bddat(prob, data, command, varargin)

switch command
  case 'init'
    res = { data.mnames };
  case 'data'
    fdata = coco_get_func_data(prob, data.tbid, 'data');
    M0    = fdata.M(fdata.M0_idx,:);
    M1    = fdata.M(fdata.M1_idx,:);
    res   = { eig(M1,M0) };
end

end
