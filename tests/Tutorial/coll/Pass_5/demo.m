addpath('../../po/adapt');

eps0 = 0.1;
t0 = linspace(0,2*pi,100)';
x0 = [ sin(t0) cos(t0) ];

prob  = coco_prob();
prob  = coco_set(prob, 'cont', 'ItMX', 100);
prob  = coco_set(prob, 'cont', 'NAdapt', 1);
prob  = coco_set(prob, 'coll', 'TOL', 1.0e-3);

prob2 = po_isol2orb(prob, '', @pneta, t0, x0, 'eps', eps0);
bd = coco(prob2, 'run1', [], 1, {'eps' 'po.period' 'po.seg.coll.err' 'po.seg.coll.NTST'}, [0.1 20]);

labs = coco_bd_labs(bd, 'EP');
prob2 = po_sol2orb(prob, '', 'run1', labs(end));
coco(prob2, 'run2', [], 1, {'eps' 'po.seg.coll.err' 'po.seg.coll.NTST'}, [0.1 20]);

figure(2)
clf

bd  = coco_bd_read('run1');
p = coco_bd_col(bd, 'eps');
err = coco_bd_col(bd, 'po.seg.coll.err');
N = coco_bd_col(bd, 'po.seg.coll.NTST');

subplot(3,1,1)

lab = coco_bd_labs(bd, 'EP');
sol1 = po_read_solution('', 'run1', lab(end));

plot(sol1.x(:,1), sol1.x(:,2), '.-');
grid on
drawnow



subplot(3,1,2)
plot(p,err, '.-');
grid on
drawnow

subplot(3,1,3)
plot(p,N, '.-');
grid on
drawnow

bd  = coco_bd_read('run2');
p = coco_bd_col(bd, 'eps');
err = coco_bd_col(bd, 'po.seg.coll.err');
N = coco_bd_col(bd, 'po.seg.coll.NTST');

subplot(3,1,2)
hold on
plot(p,err, 'r.-');
hold off
grid on
drawnow

subplot(3,1,3)
hold on
plot(p,N, 'r.-');
hold off
grid on
drawnow

rmpath('../../po/adapt');
