function prob = riess_close_het_2(prob, data)

[data1 uidx1] = coco_get_func_data(prob, 'col1.coll', 'data', 'uidx');
[data2 uidx2] = coco_get_func_data(prob, 'col2.coll', 'data', 'uidx');

prob = coco_add_func(prob, 'gap', @lingap, data, 'inactive', ...
  'lingap', 'uidx', [uidx1(data1.x1_idx); uidx2(data2.x0_idx)]);
prob = coco_add_func(prob, 'phase', @linphase, data, 'zero', ...
  'uidx', [uidx1(data1.x1_idx); uidx2(data2.x0_idx)]);
prob = coco_add_slot(prob, 'riess_save_2', @coco_save_data, data, ...
  'save_full');

end

