echo on
addpath('../../coll/Pass_2');
addpath('../../po');
%!tkn1
eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 40*pi], [0;1]);
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 6.306], x0(end,:));
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 100);
prob = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
data = coco_func_data();
data.tbid = 'po.seg.coll';
data.nseg = 1;
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
data.M{1} = repmat(eye(2), [500, 1]);
prob = coco_add_func(prob, 'var_seg', @var_seg, data, 'regular', ...
  {}, 'uidx', uidx);
prob = coco_add_func(prob, 'po_eigs', @po_eigs, data, 'regular', ...
  {'l1', 'l2'});
bd  = coco(prob, 'run1', [], 1, {'eps', 'l1', 'l2'}, [-10 10]);
%!tkn2
rmpath('../../coll/Pass_2');
rmpath('../../po');
echo off
