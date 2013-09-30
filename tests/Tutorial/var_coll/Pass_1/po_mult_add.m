%!po_mult_add
function prob = po_mult_add(prob, segoid)

data.tbid   = coco_get_id(segoid, 'var');
data.mnames = coco_get_id(segoid, 'multipliers');
prob = coco_add_slot(prob, data.tbid, @po_mult_eigs_bddat, data, ...
  'bddat');

end %!end_po_mult_add
%!po_mult_eigs_bddat
function [data res] = po_mult_eigs_bddat(prob, data, command, varargin)

switch command
  case 'init'
    res   = {data.mnames};
  case 'data'
    fdata = coco_get_func_data(prob, data.tbid, 'data');
    M1    = fdata.M(fdata.M1_idx,:);
    res   = {eig(full(M1))};
end

end %!end_po_mult_eigs_bddat