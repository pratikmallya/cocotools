%!huxley_create
function prob = huxley_close_het(prob, epsv)

[data1 uidx1] = coco_get_func_data(prob, 'huxley1.coll', ...
  'data', 'uidx');
[data2 uidx2] = coco_get_func_data(prob, 'huxley2.coll', ...
  'data', 'uidx');

prob = coco_add_glue(prob, 'shared', uidx1(data1.p_idx), ...
  uidx2(data2.p_idx));

prob = coco_add_func(prob, 'bcs', @huxley_bcs, [], 'zero', 'uidx', ...
  [uidx1(data1.x0_idx); uidx2(data2.x1_idx); uidx1(data1.p_idx)], ...
  'u0', epsv);
uidx = coco_get_func_data(prob, 'bcs', 'uidx');
data.eps_idx = [numel(uidx)-1; numel(uidx)];
prob = coco_add_slot(prob, 'bcs', @coco_save_data, data, 'save_full');

prob = coco_add_glue(prob, 'gap', uidx1(data1.x1_idx(2)), ...
  uidx2(data2.x0_idx(2)), 'gap', 'inactive');

prob = coco_add_pars(prob, 'pars', ...
  [uidx1(data1.p_idx); uidx(data.eps_idx); ...
  uidx1(data1.x1_idx(1)); uidx2(data2.x0_idx(1))], ...
  {'p1' 'p2' 'eps1' 'eps2' 'y11e' 'y21e'});

end %!end_huxley_create