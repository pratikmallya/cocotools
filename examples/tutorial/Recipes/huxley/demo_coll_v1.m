%7.3.2  A connecting orbit.

coco_use_recipes_toolbox coll_v1

p0   = [0.5; 0];
eps0 = [0.03; 0.2];
vu   = [sqrt(4*p0(1)+p0(2)^2)-p0(2); 2*p0(1)];
vu   = vu/norm(vu, 2);
segs(1).t0 = [0; 1];
x0         = eps0(1)*vu;
segs(1).x0 = [x0  x0+huxley(x0, p0)]';
segs(1).p0 = p0;
vs   = [-sqrt(4*(1-p0(1))+p0(2)^2)-p0(2); 2*(1-p0(1))];
vs   = vs/norm(vs, 2);
segs(2).t0 = [0; 1];
x0         = [1; 0]+eps0(2)*vs;
segs(2).x0 = [x0-huxley(x0, p0) x0]';
segs(2).p0 = p0;

prob = huxley_isol2het(coco_prob(), segs, eps0);
coco(prob, 'coll1', [], 1, {'y11e', 'gap'}, [0 0.5]);

prob = huxley_sol2het(coco_prob(), 'coll1', 5);
coco(prob, 'coll2', [], 1, {'y21e', 'gap'}, [0.5 1]);
prob = huxley_sol2het(coco_prob(), 'coll2', 2);
coco(prob, 'coll3', [], 1, {'gap', 'p2'}, [-0.2 0]);
prob = huxley_sol2het(coco_prob(), 'coll3', 4);
coco(prob, 'coll4', [], 1, {'eps1', 'p2'}, [1e-3 eps0(1)]);
prob = huxley_sol2het(coco_prob(), 'coll4', 3);
coco(prob, 'coll5', [], 1, {'eps2', 'p2'}, [1e-3 eps0(2)]);

clf

hold on
sol = coll_read_solution('huxley1', 'coll5', 3);
plot(sol.x(:,1), sol.x(:,2), 'r')
sol = coll_read_solution('huxley2', 'coll5', 3);
plot(sol.x(:,1), sol.x(:,2), 'r')
hold off

prob = huxley_sol2het(coco_prob(), 'coll5', 3);
coco(prob, 'coll6', [], 1, {'p1', 'p2'}, [0.25 0.75]);

bd6 = coco_bd_read('coll6');
p1 = coco_bd_col(bd6, 'p1');
p2 = coco_bd_col(bd6, 'p2');
figure(2)
plot(p1, p2, 'r.', p1, (1-2*p1)/sqrt(2), 'k')

coco_use_recipes_toolbox
