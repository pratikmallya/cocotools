coco_use_recipes_toolbox bvp_v2 coll_v1

p0 = 1;
x0 = [0.4; -1.2];
f  = @(t,x) lienard(x, p0);
[t0 x0] = ode45(f, [0 6.7], x0);
coll_args = {@lienard, t0, x0, 'p', p0};

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NPR', 1);

data = struct();
data.fhan = @lienard;
data = per_bc_update(data, [], x0(1,:)', [], p0);

bvp_args = {@per_bc, @per_bc_DFDX, data};
prob1 = bvp_isol2seg(prob, '', coll_args{:}, bvp_args{:});
coco(prob1, 'bvp1', [], 1, 'p', [-1 1]);

bvp_args = {@per_bc, @per_bc_DFDX, data, @per_bc_update};
prob2 = bvp_isol2seg(prob, '', coll_args{:}, bvp_args{:});
coco(prob2, 'bvp2', [], 1, 'p', [-1 1]);

bdf = coco_bd_read('bvp1');
bdm = coco_bd_read('bvp2');

figure(1);
clf;

subplot(1,2,1);
grid on;
labs = coco_bd_labs(bdf, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'bvp1', lab);
  plot(sol.x(:,1), sol.x(:,2), 'g.-')
  drawnow
end
for lab=labs
  sol = bvp_read_solution('', 'bvp1', lab);
  plot(sol.x(1,1), sol.x(1,2), 'k.')
  drawnow
end
hold off
subplot(1,2,2);
grid on;
labs = coco_bd_labs(bdm, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'bvp2', lab);
  plot(sol.x(:,1), sol.x(:,2), 'g.-')
  drawnow
end
for lab=labs
  sol = bvp_read_solution('', 'bvp2', lab);
  plot(sol.x(1,1), sol.x(1,2), 'k.')
  drawnow
end
hold off

coco_use_recipes_toolbox
