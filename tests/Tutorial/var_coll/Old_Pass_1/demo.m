echo on
addpath('../../coll/Pass_2');
%!tkn1
p0 = 1;
[t0 x0] = ode45(@(t,x) linode(x, p0), [0 2*pi], [0; 1; 0]);
prob = coco_prob();
funcargs = {@linode, @linode_DFDX, @linode_DFDP};
prob = coll_isol2seg(prob, '', funcargs{:}, t0, x0, 'p', p0);
[data uidx] = coco_get_func_data(prob, 'coll', 'data', 'uidx');
prob = coco_add_func(prob, 'bcs', @per_bc, [], 'zero', ...
  'uidx', [data.x0_idx ; data.x1_idx]);
% data.tbid = 'coll';
% prob = coco_add_slot(prob, 'var', @var_coll_bddat, data, 'bddat');
data = coco_func_data();
data.tbid = 'coll';
prob = coco_add_func(prob, 'var_seg', @var_seg, data, 'regular', ...
  {}, 'uidx', uidx);
prob = coco_add_func(prob, 'po_eigs', @po_eigs, data, 'regular', ...
  {'l1', 'l2', 'l3', 'cond'});
bd   = coco(prob, 'run1', [], 1, {'p', 'l1', 'l2', 'l3', 'cond'}, [0.2 2]);
%!tkn2
exp(pi*(-1-sqrt(3)*1i))
exp(pi*(-1+sqrt(3)*1i))
addpath('../../po');
%!tkn3
eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 40*pi], [0;1]);
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 6.306], x0(end,:));
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 100);
prob = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
% data.tbid = 'po.seg.coll';
% prob = coco_add_slot(prob, 'var', @var_bddat, data, 'bddat');
data = coco_func_data();
data.tbid = 'po.seg.coll';
data.nseg = 1;
uidx = coco_get_func_data(prob, 'po.seg.coll', 'uidx');
prob = coco_add_func(prob, 'var_seg', @var_seg, data, 'regular', ...
  {}, 'uidx', uidx);
prob = coco_add_func(prob, 'po_eigs', @po_eigs, data, 'regular', ...
  {'l1', 'l2', 'cond'});
bd  = coco(prob, 'run1', [], 1, {'eps', 'l1', 'l2', 'cond'}, [-10 10]);
%!tkn4
rmpath('../../coll/Pass_2');
rmpath('../../po');
echo off