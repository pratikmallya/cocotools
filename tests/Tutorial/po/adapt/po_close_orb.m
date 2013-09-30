%!po_create
function prob = po_close_orb(prob, tbid, data)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_slot(prob, tbid, @po_update, data, 'update');
segtbid      = coco_get_id(tbid, 'seg.coll');
[fdata uidx] = coco_get_func_data(prob, segtbid, 'data', 'uidx');
prob = coco_add_func(prob, tbid, @po_F, @po_DFDU, data, 'zero', ...
  'uidx', uidx(fdata.maps.xbp_idx), 'remesh', @po_remesh);
fid  = coco_get_id(tbid, 'period');
prob = coco_add_pars(prob, fid, uidx(fdata.maps.T_idx), fid, 'active');
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_po_create 
%!po_F
function [data y] = po_F(prob, data, u)

x0 = u(data.x0_idx);
x1 = u(data.x1_idx);

y = [x0-x1; data.xp0*u];

end %!end_po_F
%!po_DFDX
function [data J] = po_DFDU(prob, data, u)
  J = data.J;
end %!end_po_DFDX
%!po_update
function data = po_update(prob, data, cseg, varargin)

fid           = coco_get_id(data.tbid, 'seg.coll');
[fdata uidx]  = coco_get_func_data(prob, fid, 'data', 'uidx');
u             = cseg.src_chart.x;
data.xp0      = u(uidx(fdata.maps.xbp_idx))'*data.intfac;
data.J(end,:) = data.xp0;

end %!end_po_update
%!po_remesh
function [prob status xtr] = ...
  po_remesh(prob, data, chart, old_u, old_V)

xtr    = [];
data   = po_init_data(prob, data.tbid, data);
fid          = coco_get_id(data.tbid, 'seg.coll');
[fdata uidx] = coco_get_func_data(prob, fid, 'data', 'uidx');
prob   = coco_change_func(prob, data, 'uidx', uidx(fdata.maps.xbp_idx));
status = 'success';

end %!end_po_remesh