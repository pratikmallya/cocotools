%!po_create
function prob = po_close_orb(prob, tbid, data)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_slot(prob, tbid, @po_update, data, 'update');
segtbid      = coco_get_id(tbid, 'seg.coll');
[fdata uidx] = coco_get_func_data(prob, segtbid, 'data', 'uidx');
prob = coco_add_func(prob, tbid, @po_F, @po_DFDU, data, 'zero', ...
  'uidx', uidx(fdata.xbp_idx));
fid  = coco_get_id(tbid, 'period');
prob = coco_add_pars(prob, fid, uidx(fdata.T_idx), fid, 'active');
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

if data.po.bifus
  segoid = coco_get_id(tbid, 'seg');
  prob = var_coll_add(prob, segoid);
  data.var_id = coco_get_id(segoid, 'var');
  tfid = coco_get_id(tbid, 'test');
  data.tfid = tfid;
  tfps = coco_get_id(tfid, {'SN' 'PD' 'NS' 'stab'});
  prob = coco_add_chart_data(prob, tfid, [], []);
  prob = coco_add_func(prob, tfid, @po_TF, data, ...
    'regular', tfps, 'requires', data.var_id, 'passChart');
  prob = coco_add_event(prob, 'SN', tfps{1}, 0);
  prob = coco_add_event(prob, 'PD', tfps{2}, 0);
  prob = coco_add_event(prob, @po_evhan_NS, data, tfps{3}, 0);
end

end %!end_po_create