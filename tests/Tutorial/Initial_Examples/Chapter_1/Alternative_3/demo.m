addpath('../../../calc_var')

seg.t0 = 0:0.01:1;
seg.x0  = cosh(seg.t0);
prob = coco_prob();
prob = coco_set(prob, 'calcvar', 'ParNames', 'Y');
prob = calcvar_start(prob, '', @catenary, seg, cosh(1));
prob = coco_add_event(prob, 'UZ', 'Y', 0:.5:5);
bd   = coco(prob, 'run', [], 1, 'Y', [0.1 5]);

labs = coco_bd_labs(bd, 'UZ');

figure(1)
clf
hold on
grid on
for lab=labs
  [t,x]  = calcvar_read_sol('', 'run', lab);
  plot(t, x, 'r.-')
  drawnow
end
hold off

rmpath('../../../calc_var')