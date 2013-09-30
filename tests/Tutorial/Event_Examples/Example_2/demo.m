echo on
addpath('../../coll/Pass_1')
addpath('../../hspo')
addpath('../../msbvp')
%!tkn1
p0     = [1; 0.1; 1; 1; 1; 0.8];
modes  = {'free' 'free'};
events = {'impact' 'phase'};
resets = {'bounce' 'phase'};
f       = @(t, x) impact(x, p0, modes{1});
[t1 x1] = ode45(f, [0 3.2], [-0.98; -0.29; -pi]);
f       = @(t, x) impact(x, p0, modes{2});
[t2 x2] = ode45(f, [0 3.1], [1; -1.36; 0.076]);
t0 = {t1  t2};
x0 = {x1  x2};
hspo_args = {{@impact, @impact_events, @impact_resets}, ...
  modes, events, resets, t0, x0, {'k' 'c' 'A' 'w' 'd' 'e'}, p0};
prob = hspo_isol2segs(coco_prob(), '', hspo_args{:});
%!tkn2
[data uidx] = coco_get_func_data(prob, 'msbvp.seg2.coll', ...
  'data', 'uidx');
prob = coco_add_pars(prob, 'grazing', uidx(data.x0_idx(2)), ...
  'graze', 'active');
prob = coco_add_event(prob, 'GR', 'graze', 0);
%!tkn3
prob = coco_set(prob, 'cont', 'ItMX', 100);
coco(prob, 'run1', [], {'A' 'graze'}, [0.01 1]);
%!tkn4

figure(1)
clf
subplot(2,2,1);

bd1 = coco_bd_read('run1');
A = coco_bd_col(bd1, 'A');
y = coco_bd_col(bd1, '||U||'); %'graze');
plot(A,y,'.-');
hold on
idx = coco_bd_idxs(bd1, 'EP');
plot(A(idx),y(idx),'go');
idx = coco_bd_idxs(bd1, 'GR');
plot(A(idx),y(idx),'ro');
hold off
grid on
drawnow

subplot(2,2,2);
sol = msbvp_read_solution('', 'run1', 1);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

subplot(2,2,3);
sol = msbvp_read_solution('', 'run1', 6);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

subplot(2,2,4);
sol = msbvp_read_solution('', 'run1', 11);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

drawnow

%!tkn5
labgr = coco_bd_labs(bd1, 'GR');
prob = msbvp_sol2segs(coco_prob(), '', 'run1', labgr);
[data uidx] = coco_get_func_data(prob, 'msbvp.seg2.coll', ...
  'data', 'uidx');
prob = coco_add_pars(prob, 'grazing', uidx(data.x0_idx(2)), ...
  'graze', 'active');
prob = coco_xchg_pars(prob, 'graze', 'A');
prob = coco_set(prob, 'cont', 'ItMX', 100);
coco(prob, 'run2', [], {'w' 'A' 'graze'}, {[] [0 1]});
%!tkn6

bd2 = coco_bd_read('run2');
figure(2)

subplot(2,2,1);
A = coco_bd_col(bd2, 'A');
w = coco_bd_col(bd2, 'w');
plot(A,w,'.-');
hold on
idx = coco_bd_idxs(bd2, 'EP');
plot(A(idx),w(idx),'go');
hold off
grid on
drawnow

subplot(2,2,2);
sol = msbvp_read_solution('', 'run2', 11);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

subplot(2,2,3);
sol = msbvp_read_solution('', 'run2', 1);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

subplot(2,2,4);
sol = msbvp_read_solution('', 'run2', 16);
plot(sol{1}.x(:,1),sol{1}.x(:,2),'.-', sol{2}.x(:,1),sol{2}.x(:,2),'r.-');
grid on

drawnow

rmpath('../../msbvp')
rmpath('../../hspo')
rmpath('../../coll/Pass_1')
echo off