echo on
addpath('../');
addpath('../../../po');
addpath('../../../bvp');
addpath('../../../coll/Pass_1');
%!tkn1
[t0 x0] = ode45(@(t,x) linode(x, 1), [0 2*pi], [0; 1; 0]);
coll_args = {@linode, @linode_DFDX, @linode_DFDP, t0, x0, 'p', 1};
prob = bvp_isol2seg(coco_prob(), '', coll_args{:}, @lin_bc);
%!tkn2
prob = var_coll_add(prob, 'bvp.seg', @linode_DFDXDX, @linode_DFDXDP);
prob = po_mult_add(prob, 'bvp.seg');
coco(prob, 'var1', [], 1, 'p', [0.2 2]);
%!tkn3
rmpath('../../../coll/Pass_1');
rmpath('../../../bvp');
rmpath('../../../po');
rmpath('../');
echo off