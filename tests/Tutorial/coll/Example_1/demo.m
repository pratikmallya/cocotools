% - changed initial solution to one explicit Euler step with h=0.04

addpath('../Pass_1')
echo on
%!tkn1
t0 = [0; 0.04];
x0 = [1 0; 1 0.04];
%!tkn2
prob = coll_isol2seg(coco_prob(), '', @catenary, t0, x0, []);
%!tkn3
data = coco_get_func_data(prob, 'coll', 'data');
%!tkn4
%!tkn5
prob = coco_add_pars(prob, 'pars', ...
    [data.x0_idx; data.x1_idx(1); data.T_idx], ...
    {'y1s' 'y2s' 'y1e' 'T'});
%!tkn6
coco(prob, 'run1', [], 1, {'T' 'y1e'}, [0 1]);
%!tkn7
sol = coll_read_solution('', 'run1', 5);
plot(sol.t, sol.x(:,1), 'r')
%!tkn8
prob = coll_sol2seg(coco_prob(), '', 'run1', 5);
data = coco_get_func_data(prob, 'coll', 'data');
prob = coco_add_pars(prob, 'pars', ...
  [data.x0_idx; data.x1_idx(1); data.T_idx], ...
  {'y1s' 'y2s' 'y1e' 'T'});
coco(prob, 'run2', [], 1, {'y1e' 'y2s'}, [0 3]);
%!tkn9
bd2 = coco_bd_read('run2');
labs = coco_bd_labs(bd2, 'EP');
hold on
grid on
for lab=labs
  sol = coll_read_solution('', 'run2', lab);
  plot(sol.t, sol.x(:,1), 'b')
  drawnow
end
hold off

rmpath('../Pass_1')
echo off