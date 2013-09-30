%

coco_use_recipes_toolbox coll_v1 bvp_v1

t0 = [0; 1];
x0 = [1 0; 1 0];
Y0 = 1;
coll_args = {@catenary, t0, x0, 'Y', Y0};
bvp_args  = [coll_args, {@catenary_bc, @catenary_bc_DFDX}];
prob      = bvp_isol2seg(coco_prob(), '', bvp_args{:});
coco(prob, 'bvp1', [], 1, 'Y', [0 3]);

bd = coco_bd_read('bvp1');
labs = coco_bd_labs(bd, 'all');
figure(1)
clf
hold on
grid on
for lab=labs
  sol = bvp_read_solution('', 'bvp1', lab);
  plot(sol.t, sol.x(:,1), 'k.-')
  drawnow
end
hold off

coco_use_recipes_toolbox
