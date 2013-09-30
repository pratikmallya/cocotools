%% set up duffing equation

f  = @(x,p) duffing(x,p);
fx = @(x,p) duffing_DX(x,p);
fp = @(x,p) duffing_DP(x,p);

g  = @(x,p, x0,f0) [x(1:end-1);x(end)-2*pi/p(end)];
gx = @(x,p, x0,f0) eye(numel(x));
gp = @(x,p, x0,f0) [zeros(numel(x)-1,numel(p));zeros(1,numel(p)-1) 2*pi/p(end)^2];

h  = @(x,p, x0,f0) x(end)-2*pi/p(end);
hx = @(x,p, x0,f0) [zeros(1,numel(x)-1) 1];
hp = @(x,p, x0,f0) [zeros(1,numel(p)-1) 2*pi/p(end)^2];

% compute initial point using simulation
x0 = [0.1;0.1;0];
p0 = [0.2;1;1;1;1];
T0 = 2*pi/p0(5);

[t z] = ode45(@(t,x) f(x,p0),[0,10*T0],x0);
x0    = [z(end,1:2)';0];

% define parameter names
opts = [];
opts = coco_set(opts, 'curve', 'ParNames', {'la' 'al' 'eps' 'A' 'om'});

%% computation of frequency response curve

if false && coco_run_exist('1')
  bd1 = coco_bd_read('1');
else
  bd1 = coco(opts, '1', 'po_curve', 'isol', 'sol', ...
    f, fx, fp, g, gx, gp, h, hx, hp, x0, p0, T0, ...
    'om', [0.25 3]);
end

u  = coco_bd_col(bd1, {'om' '||x||'});

plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow

%% continuation in forcing amplitude

A = 1;
ome = 1;
con_par = 'A';
con_int = [0;70];

ode_opts = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-8, 'NormControl', 'on');
opts = coco_set(opts, 'curve', 'ode_opts', ode_opts);
opts = coco_set(opts, 'cont', 'ItMX', 500);

if coco_run_exist('2')
  bd2 = coco_bd_read('2');
else
  bd2 = coco(opts, '2', 'po_curve', 'isol', 'sol', ...
    f, fx, fp, g, gx, gp, h, hx, hp, x0, p0, T0, ...
    'A', [0 70]);
end

u  = coco_bd_col(bd2, {'A' '||x||'});

plot(u(1,:), u(2,:), 'b.-')
grid on
drawnow

%% Branch switching

labs = coco_bd_labs(bd2, 'BP');

% first loop
opts = coco_set(opts, 'cont', 'ItMX', 70);
if coco_run_exist('3')
  bd3 = coco_bd_read('3');
else
  bd3 = coco(opts, '3', 'po_curve', 'BP', 'sol', ...
    '2', labs(1), 'A', [0 70]);
end

u  = coco_bd_col(bd3, {'A' '||x||'});
hold on
plot(u(1,:), u(2,:), 'b.-')
grid on
hold off
drawnow

% second loop
opts = coco_set(opts, 'cont', 'ItMX', 250);
if coco_run_exist('4')
  bd4 = coco_bd_read('4');
else
  bd4 = coco(opts, '4', 'po_curve', 'BP', 'sol', ...
    '2', labs(3), 'A', [0 70]);
end

u  = coco_bd_col(bd4, {'A' '||x||'});
hold on
plot(u(1,:), u(2,:), 'b.-')
grid on
hold off
drawnow
