echo on
%% linear ode
addpath('../../coll/Pass_1');
%!tkn1
p0 = 1;
[t0 x0] = ode45(@(t,x) linode(x, p0), [0 2*pi], [0; 1; 0]);
prob = coco_prob();
funcargs = {@linode, @linode_DFDX, @linode_DFDP};
prob = coll_isol2seg(prob, '', funcargs{:}, t0, x0, 'p', p0);
[data uidx] = coco_get_func_data(prob, 'coll', 'data', 'uidx');
prob = coco_add_func(prob, 'bcs', @per_bc, [], 'zero', ...
  'uidx', [data.x0_idx ; data.x1_idx]);
prob = var_coll_add(prob, '', 'left');
prob = po_mult_add(prob, '');
bd   = coco(prob, 'run1', [], 1, {'p', 'mult.|m1|', 'mult.|m2|', ...
  'mult.|m3|'}, [0.2 2]);
%!tkn2
exp(pi*(-1-sqrt(3)*1i))
exp(pi*(-1+sqrt(3)*1i))
rmpath('../../coll/Pass_1');
return
%% pneta example
addpath('../../coll/Pass_1');
addpath('../../po');
%!tkn3
eps0 = 0.5;
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 40*pi], [0;1]);
[t0 x0] = ode45(@(t,x) pneta(x, eps0, []), [0 6.306], x0(end,:));
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 100);
prob = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
prob = var_coll_add(prob, 'po.seg', 'average');
prob = po_mult_add(prob, 'po.seg');
bd  = coco(prob, 'run1', [], 1, {'eps', 'po.seg.mult.|m1|', ...
  'po.seg.mult.|m2|', 'po.seg.var.cond', 'po.seg.var.||M||', 'po.seg.var.det'}, [-10 10]);
%!tkn4
rmpath('../../coll/Pass_1');
rmpath('../../po');
echo off