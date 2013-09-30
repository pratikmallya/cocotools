% - changed initial guess to constant function for Y0 = 1
% - changed continuation interval to get more solutions

echo on
addpath('../../coll/Pass_1')
addpath('../')
%!tkn1
t0 = [0; 1];
x0 = [1 0; 1 0];
Y0 = 1;
coll_args = {@catn, t0, x0, 'Y', Y0};
bvp_args = [coll_args, {@catn_bc, @catn_bc_DFDX}];
prob = bvp_isol2seg(coco_prob(), '', bvp_args{:});
coco(prob, 'run', [], 1, 'Y', [0 3]);
%!tkn2
bd = coco_bd_read('run');
labs = coco_bd_labs(bd, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  plot(sol.t, sol.x(:,1), 'k.-')
  drawnow
end
hold off

rmpath('../../coll/Pass_1')
rmpath('../')
echo off