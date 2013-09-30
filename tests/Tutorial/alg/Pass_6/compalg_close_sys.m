function prob = compalg_close_sys(prob, tbid, data)

sidx = cell(1, data.neqs);
for i=1:data.neqs
  stbid   = coco_get_id(tbid, sprintf('eqn%d.alg', i));
  [fdata uidx] = coco_get_func_data(prob, stbid, 'data', 'uidx');
  sidx{i} = uidx(fdata.p_idx);
end
for i=2:data.neqs
  fid  = coco_get_id(tbid, sprintf('shared%d', i-1));
  prob = coco_add_glue(prob, fid, sidx{1}, sidx{i});
end
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, sidx{1}, data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end