
addpath('../../Atlas_Algorithms/Pass_10/');

prob = coco_prob();
prob = coco_set(prob, 'alg', 'HB', true, 'FO', 'regular');
prob = coco_set(prob, 'alg', 'NSad', true);
prob = coco_set(prob, 'cont', 'atlas', @atlas_2d_min.create);
prob = coco_set(prob, 'cont', 'PtMX', 1000,'h',0.15);
prob = alg_isol2eqn(prob, '', @popul, [1.76; 1.52], {'p1' 'p2'}, [0.3; 0.1]);
prob = coco_add_pars(prob, 'pars', [1 2], {'x', 'y'});
coco(prob, 'run', [], 2, {'p1' 'p2' 'x' 'y' }, {[0 0.5], [0 0.25], [0 10], [0 10]});


atlas = coco_bd_read('run', 'atlas');
figure(1)
clf

subplot(1,2,1)
hold on
bd = coco_bd_read('run');
idx1 = coco_bd_idxs(bd, 'HB');
idx2 = coco_bd_idxs(bd, 'FO');
idx3 = coco_bd_idxs(bd, 'NSad');
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
plot(p1(idx1),p2(idx1),'k.', p1(idx2),p2(idx2),'ko')
grid on
drawnow

subplot(1,2,2)
plot(p1(idx1),p2(idx1),'k.', p1(idx2),p2(idx2),'ko', ...
  p1(idx3),p2(idx3),'kx')
grid on
drawnow

rmpath('../../Atlas_Algorithms/Pass_10/');