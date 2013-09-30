% 7.3.1  A shooting method for boundary-value problems.
%
% Demonstrate computation of a family of solutions to the catenary problem
% by forward shooting using one instance of the collocation toolbox defined
% in Chapter 7 of Recipes for Continuation.
%
%   See also: catenary

coco_use_recipes_toolbox coll_v1

t0 = [0; 0.04];
x0 = [1 0; 1 0.04];

prob = coll_isol2seg(coco_prob(), '', @catenary, t0, x0, []);

data = coco_get_func_data(prob, 'coll', 'data');

prob = coco_add_pars(prob, 'pars', ...
  [data.x0_idx; data.x1_idx(1); data.T_idx], ...
  {'y1s' 'y2s' 'y1e' 'T'});

coco(prob, 'coll1', [], 1, {'T' 'y1e'}, [0 1]);

sol = coll_read_solution('', 'coll1', 5);
plot(sol.t, sol.x(:,1), 'r')

prob = coll_sol2seg(coco_prob(), '', 'coll1', 5);
data = coco_get_func_data(prob, 'coll', 'data');
prob = coco_add_pars(prob, 'pars', ...
  [data.x0_idx; data.x1_idx(1); data.T_idx], ...
  {'y1s' 'y2s' 'y1e' 'T'});
coco(prob, 'coll2', [], 1, {'y1e' 'y2s'}, [0 3]);

bd2 = coco_bd_read('coll2');
labs = coco_bd_labs(bd2, 'EP');
hold on
grid on
for lab=labs
  sol = coll_read_solution('', 'coll2', lab);
  plot(sol.t, sol.x(:,1), 'b')
  drawnow
end
hold off

coco_use_recipes_toolbox
