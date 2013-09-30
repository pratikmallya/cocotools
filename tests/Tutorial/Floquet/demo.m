addpath('../')
addpath('../../alg/Pass_5')

p0 = [1; 1];
eps0 = [0.01; 0.03];
th0 = -pi/2;
eqs10 = [-1; 1];
eqs20 = [1; -1];
vec0 = [-3/sqrt(10); 1/sqrt(10)];
lam0 = 2;

segs(1).mode  = 1;
segs(1).t0    = [0 ; 0.01];
segs(1).x0    = [eqs10 + eps0(1)*[cos(th0); sin(th0)], ...
    eqs10 + eps0(1)*1.01*[cos(th0); sin(th0)]]';

segs(2).mode  = 2;
segs(2).t0    = [0 ; 0.01];
segs(2).x0    = [eqs20 + eps0(2)*vec0, eqs20 + eps0(2)*1.01*vec0]';

opts = doedel_start([], segs, p0, eps0, th0, eqs10, eqs20, vec0, lam0);
bd1 = coco(opts, 'run1', [], 1, {'y12e', 'gap'}, [0 0.99]);

opts = doedel_restart([], 'run1', 5);
bd2 = coco(opts, 'run2', [], 1, {'y22e', 'gap'}, [-0.995 0]);

opts = doedel_restart([], 'run2', 4);
bd3 = coco(opts, 'run3', [], 1, {'gap', 'p1'}, [-2 0]);

opts = doedel_restart([], 'run3', 4);
bd4 = coco(opts, 'run4', [], 1, {'eps1', 'p1'}, [1e-3 1.1e-2]);

opts = doedel_restart([], 'run4', 4);
bd5 = coco(opts, 'run5', [], 1, {'eps2', 'p2'}, [1e-3 3.1e-2]);

opts = doedel_restart([], 'run5', 4);
bd6 = coco(opts, 'run6', [], 1, {'p2', 'eps1'}, [0 3]);

labs = coco_bd_labs(bd6, 'ALL');
for lab=labs
clf
hold on
[t,x]  = coll_read_sol('col1', 'run6', lab); %#ok<ASGLU>
plot(x(1,:), x(2,:), 'r.')
[t,x]  = coll_read_sol('col2', 'run6', lab);
plot(x(1,:), x(2,:), 'r.')
hold off
drawnow
pause
end
