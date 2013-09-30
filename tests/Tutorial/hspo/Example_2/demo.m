echo on
addpath('../../coll/Pass_2')
addpath('../../msbvp')
addpath('../')
% [t1, x1] = ode45(f, [0  1.7198], [0.5; 0; -0.0095526]);
% [t2, x2] = ode45(f, [0  1.699], [0.25073; 0.0043073; -1.5708]);
% p0 = [0.58762; 0.04; 3.1784; 0.9189; 0.8];
%!tkn1
p0 = [0.59; 0.04; 3.17; 0.92; 0.80];
modes  = {'stick' 'stick'};
events = {'phase' 'minsep'};
resets = {'phase' 'turn'};
f  = @(t, x) stickslip(x, p0, modes{1});
[t1, x1] = ode45(f, [0  1.5], [0.5; 0; 0]);
f  = @(t, x) stickslip(x, p0, modes{2});
[t2, x2] = ode45(f, [0  1.5], [0.25; 0; -pi/2]);
t0 = {t1 t2};
x0 = {x1 x2};
prob = hspo_isol2segs(coco_prob(), '', ...
  {@stickslip, @stickslip_events, @stickslip_resets}, ...
  {@stickslip_DFDX, [], []}, modes, events, resets, ...
  t0, x0, {'V' 'c' 'n' 'w' 'e'}, p0);
coco(prob, 'run1', [], 1, 'V', [0.5 0.7]);
%!tkn2
bd = coco_bd_read('run1');
labs = coco_bd_labs(bd, 'EP');
figure(1)
clf
hold on
for lab=labs
  sol = msbvp_read_solution('', 'run1', lab);
  plot(sol{1}.x(:,1), sol{1}.x(:,2), 'k.-')
  plot(sol{2}.x(:,1), sol{2}.x(:,2), 'r.-')
end
hold off
%% Different segmentation
%!tkn3
[data uidx] = coco_get_func_data(prob, 'msbvp', 'data', 'uidx');
prob = coco_add_pars(prob, 'graze', uidx(data.x0_idx(1)), 'pos');
prob = coco_set_parival(prob, 'pos', 0.5);
coco(prob, 'graze_run', [], 0, {'V' 'pos'});
%!tkn4
sol = msbvp_read_solution('', 'graze_run', 1);
modes  = {'stick' 'stick' 'slip'};
events = {'phase' 'collision' 'rest'};
resets = {'phase' 'bounce' 'stick'};
t0 = {sol{1}.t, sol{2}.t, 0};
x0 = {sol{1}.x, sol{2}.x, [0 sol{1}.x(1,:)]};
prob = hspo_isol2segs(coco_prob(), '', ...
  {@stickslip, @stickslip_events, @stickslip_resets}, ...
  {@stickslip_DFDX, [], []}, modes, events, resets, ...
  t0, x0, {'V' 'c' 'n' 'w' 'e'}, p0);
coco(prob, 'run2', [], 1, 'V', [0.5 0.7]);
%!tkn5
bd = coco_bd_read('run2');
labs = coco_bd_labs(bd, 'EP');
figure(2)
clf
hold on
for lab=labs
  sol = msbvp_read_solution('', 'run2', lab);
  plot(sol{1}.x(:,1), sol{1}.x(:,2), 'k.-')
  plot(sol{2}.x(:,1), sol{2}.x(:,2), 'r.-')
  plot(sol{3}.x(:,2), sol{3}.x(:,3), 'b.-')
end
hold off

rmpath('../')
rmpath('../../msbvp')
rmpath('../../coll/Pass_2')