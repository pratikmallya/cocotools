coco_use_recipes_toolbox coll_v1 bvp_v1

coll_args = {@bratu, [0;1], zeros(2), 'p', 0};
bvp_args  = [coll_args, {@bratu_bc, @bratu_bc_DFDX}];
prob      = coco_prob();
coco(prob, 'bvp1', @bvp_isol2seg, bvp_args{:}, 1, 'p', [0 4]);

bd   = coco_bd_read('bvp1');
par  = coco_bd_col(bd, 'p');
nrmx = coco_bd_col(bd, '||U||');

figure(1);
clf;

plot(par, nrmx, 'b.-');
title('Bifurcation diagram');
grid on;
drawnow

figure(2);
clf;

labs = coco_bd_labs(bd, 'all');
subplot(1,2,1);
title('u');
hold on;
subplot(1,2,2);
title('u''');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'bvp1', lab);
  subplot(1,2,1);
  plot(sol.t, sol.x(:,2), '.-');
  subplot(1,2,2);
  plot(sol.t, sol.x(:,1), '.-');
end
subplot(1,2,1);
hold off;
grid on;
subplot(1,2,2);
hold off;
grid on;
drawnow

coco_use_recipes_toolbox

return %#ok<*UNRCH>

%% test restart of bvp

prob = coco_prob();
bd = coco(prob, 'run2', @bvp_sol2seg, 'run', 6, 1, 'p', [0 3.5]);

par  = coco_bd_col(bd, 'p');
nrmx = coco_bd_col(bd, '||U||');
subplot(2,1,1);
hold on
plot(par, nrmx, 'r.-');
hold off
grid on;
drawnow

labs = coco_bd_labs(bd, 'all');
subplot(2,1,2);
grid on;
hold on;
for lab=labs
  sol = bvp_read_solution('', 'run2', lab);
  plot(sol.t, sol.x(:,2), 'r.-');
  plot(sol.t, sol.x(:,1), 'm.-');
end
hold off;

rmpath('../../coll/Pass_1')
rmpath('../')
echo off