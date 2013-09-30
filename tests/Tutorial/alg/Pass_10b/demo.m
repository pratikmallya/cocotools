% - a final plot will show the analytical curve in the background of the
%   points along the Hopf curve
echo on
addpath('../../Atlas_Algorithms/Pass_10/');
%!tkn1
alg_args = {@popul, [1.76; 1.52], {'p1' 'p2'}, [0.3; 0.1]};
prob = alg_isol2eqn(coco_prob(), '', alg_args{:});
prob = coco_add_pars(prob, 'pars', [1 2], {'x', 'y'});
prob = coco_set(prob, 'cont', 'h', 0.15, 'PtMX', 1000);
coco(prob, 'run', [], 2, {'p1' 'p2' 'x' 'y' }, ...
  {[0 0.5], [0 0.25], [0 10], [0 10]});
%!tkn2
atlas = coco_bd_read('run', 'atlas');
figure(1)
clf

subplot(1,2,1)
hold on
[tri X C] = plot_trisurf(atlas.charts, 3,4,1);
trisurf(tri, X(:,1), X(:,2), X(:,3), 'FaceColor', 0.8*[1 1 1], ...
  'EdgeColor', 0.7*[1 1 1], 'LineWidth', 0.5);

bd = coco_bd_read('run');
idx1 = coco_bd_idxs(bd, 'HB');
idx2 = coco_bd_idxs(bd, 'FO');
idx3 = coco_bd_idxs(bd, 'EP');
x = coco_bd_col(bd, 'x');
y = coco_bd_col(bd, 'y');
p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
plot3(p1(idx1),p2(idx1),x(idx1),'ko','MarkerFaceColor','k')
plot3(p1(idx2),p2(idx2),x(idx2),'ko','MarkerFaceColor','w')
plot3(p1(idx3),p2(idx3),x(idx3),'ko','MarkerFaceColor','y')
hold off
axis tight
view([-10 40])
grid on
drawnow

subplot(1,2,2)
plot(p1(idx1),p2(idx1),'k.', p1(idx2),p2(idx2),'ko')
grid on
drawnow

rmpath('../../Atlas_Algorithms/Pass_10/');
echo off