% changed NPR to 1, so we can plot the full family

echo on
addpath('../../coll/Pass_1')
%!tkn1
p0 = 1;
x0 = [0.4; -1.2];
f  = @(t,x) lienard(x, p0);
[t0 x0] = ode45(f, [0 6.7], x0);
coll_args = {@lienard, t0, x0, 'p', p0};
data = struct();
data.fhan = @lienard;
data = per_bc_update(data, [], x0(1,:)', [], p0);
%!tkn2
bvp_args = {@per_bc, @per_bc_DFDX, data, @per_bc_update};
prob = bvp_isol2seg(coco_prob(), '', coll_args{:}, bvp_args{:});
coco(prob, 'run_moving', [], 1, 'p', [-1 1]);
%!tkn3
bvp_args = {@per_bc, @per_bc_DFDX, data};
prob = bvp_isol2seg(coco_prob(), '', coll_args{:}, bvp_args{:});
coco(prob, 'run_fixed', [], 1, 'p', [-1 1]);
%!tkn4
echo off
% prob = coco_set(prob, 'cont', 'FP', true);
% coco(prob, 'run_fixed', [], 1, 'p', [-1, 1]);
bvp_args = {@per_bc, @per_bc_DFDX, data, @per_bc_update};
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NPR', 1);
prob = bvp_isol2seg(prob, '', coll_args{:}, bvp_args{:});
coco(prob, 'run_moving', [], 1, 'p', [-1 1]);
bdm = coco_bd_read('run_moving');
bvp_args = {@per_bc, @per_bc_DFDX, data};
prob = coco_set(coco_prob(), 'cont', 'NPR', 1);
prob = bvp_isol2seg(prob, '', coll_args{:}, bvp_args{:});
coco(prob, 'run_fixed', [], 1, 'p', [-1 1]);
bdf = coco_bd_read('run_fixed');
clf;
subplot(1,2,1);
grid on;
labs = coco_bd_labs(bdf, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'run_fixed', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
  drawnow
end
for lab=labs
  sol = bvp_read_solution('', 'run_fixed', lab);
  plot(sol.x(1,1), sol.x(1,2), 'k.')
  drawnow
end
hold off
subplot(1,2,2);
grid on;
labs = coco_bd_labs(bdm, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'run_moving', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
  drawnow
end
for lab=labs
  sol = bvp_read_solution('', 'run_moving', lab);
  plot(sol.x(1,1), sol.x(1,2), 'k.')
  drawnow
end
hold off
rmpath('../../coll/Pass_1')