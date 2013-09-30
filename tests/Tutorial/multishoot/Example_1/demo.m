addpath('..');

p0 = [-0.59 ; 0.5 ; -0.6 ; 0.6 ; 0.328578 ; 0.933578];
x0 = [0.177 ; 0.082 ; 0.183];
T0 = 9;
N  = 4;

for i=2:N
  [t x] = ode45(@(t,x) tor(x,p0), [0 T0/N], x0(:,end));
  x0 = [x0 x(end,:)'];
end

ev_data = tor_update([], x0, p0, []);

prob = coco_prob();
prob = coco_set(prob, 'all', 'TOL', 1.0e-4);
prob = coco_set(prob, 'mshoot', 'bifus', true);
prob = multishoot_create(prob, @tor, @tor_dx, @tor_dp, ...
  @event, @event_dx, @event_dp, ...
  @jump,  @jump_dx,  @jump_dp, @tor_update, ev_data, ...
  x0, {'nu' 'be' 'ga' 'r' 'a3' 'b3'}, p0, 1:N);
bd1 = coco(prob, 'run1', [], 1, 'nu', [-0.65, -0.55]);

rmpath('..');
