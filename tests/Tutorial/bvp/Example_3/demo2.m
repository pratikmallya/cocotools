echo on
addpath('../../coll/Pass_1')
%!tkn1
p0        = [0.16; 1250; 0.05; 20; 1.1; 0.001; 3; 0.6; 0.12];
f         = @(t,x) chemosz(x, p0);
[t0 x0]   = ode15s(f, [0 14], [21; 3; 0; 0]);
coll_args = {@chemosz, t0, x0, ...
  {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'}, p0};
data.fhan = @chemosz;
data = per_bc_update(data, [], x0(end,:)', [], p0);
bvp_args = {@per_bc, @per_bc_DFDX, data, @per_bc_update};
%!tkn2
prob = coco_set(coco_prob(), 'bvp.coll', 'NTST', 40);
prob = bvp_isol2seg(prob, '', coll_args{:}, bvp_args{:});
coco(prob, 'run', [], 1, 'g', [2 4]);
%!tkn3
bd = coco_bd_read('run');
cla;
grid on;
labs = coco_bd_labs(bd, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  plot3(sol.x(:,1), sol.x(:,2), sol.x(:,3), 'b.-')
end
hold off
view(130,15)
rmpath('../../coll/Pass_1')
echo off