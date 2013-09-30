% - changed continuation interval to get more solutions
% - second run now has run id 'run2' and doesn't overwrite 'run'

echo on
addpath('../../coll/Pass_1')
addpath('../')
%!tkn1
coll_args = {@brat, [0;1], zeros(2), 'p', 0};
bvp_args  = [coll_args, {@brat_bc, @brat_bc_DFDX}];
prob = coco_prob();
coco(prob, 'run', @bvp_isol2seg, bvp_args{:}, 1, 'p', [0 4]);
%!tkn2
bd = coco_bd_read('run');
par = coco_bd_col(bd, 'p');
nrmx = coco_bd_col(bd, '||U||');
%!tkn3
subplot(2,1,1);
plot(par, nrmx, 'b.-');
grid on;
drawnow
subplot(2,1,2);
cla;
grid on;
%!tkn5
labs = coco_bd_labs(bd, 'all');
hold on;
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  plot(sol.t, sol.x(:,2), 'b.-');
  plot(sol.t, sol.x(:,1), 'g.-');
end
hold off;
%!tkn6
drawnow

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