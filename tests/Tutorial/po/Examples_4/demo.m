tbx = {'../../coll/Pass_1', '../../var_coll/Pass_1', '../../po/events'};
addpath(tbx{:})

p0 = [-0.59 ; 0.5 ; -0.6 ; 0.6 ; 0.328578 ; 0.933578];
x0 = [0.177 ; 0.082 ; 0.183];
T0 = 9;
N  = 1;

[t0 x0] = ode45(@(t,x) tor(x,p0), [0 T0/N], x0(:,end));

prob = coco_prob();
prob = coco_set(prob, 'po', 'bifus', true);
prob = coco_set(prob, 'cont', 'FP', true, 'BP', true);
prob = po_isol2orb(prob, '', @tor, @tor_dx, @tor_dp, t0, x0, ...
  {'nu' 'be' 'ga' 'r' 'a3' 'b3'}, p0);
bd1 = coco(prob, 'run1', [], 1, {'nu' 'po.period'}, [-0.65, -0.55]);

labs = coco_bd_labs(bd1, 'PD');
[data chart] = coco_read_solution('', 'run1', labs(1));
pd   = coco_get_chart_data(chart, 'po.PD');
prob = coco_prob();
prob = coco_set(prob, 'po', 'bifus', true);
prob = coco_set(prob, 'cont', 'FP', true, 'BP', true);
prob = po_isol2orb(prob, '', @tor, @tor_dx, @tor_dp, pd.pd_t0, ...
  pd.pd_x0, {'nu' 'be' 'ga' 'r' 'a3' 'b3'}, pd.pd_p);
bd2 = coco(prob, 'run2', [], 1, {'nu' 'po.period'}, [-1, -0.55]);

labs = coco_bd_labs(bd2, 'all');
clf
hold on
grid on
for lab=labs
  sol = po_read_solution('','run2', lab);
  plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'r')
end
hold off


rmpath(tbx{:})
