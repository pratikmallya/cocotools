addpath('../../../coll/Pass_1')
addpath('../../../bvp')

t0 = (0:0.01:1)';
x0 = [cosh(t0) sinh(t0)];
prob = coco_prob();
prob = coco_set(prob, 'cont', 'ItMX', 200);
prob = bvp_isol2seg(prob, '', @catenary, t0, x0, 'Y', cosh(1), ...
    @catenary_bc, @catenary_bc_DFDX);
prob = coco_add_event(prob, 'UZ', 'Y', 0:0.5:5);
bd   = coco(prob, 'run', [], 1, 'Y', [0.1, 5]);
labs = coco_bd_labs(bd, 'UZ');

figure(1)
clf
hold on
grid on
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  plot(sol.t, sol.x(:,1), 'r.-')
  drawnow
end
hold off

rmpath('../../../coll/Pass_1')
rmpath('../../../bvp')