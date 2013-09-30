coco_use_recipes_toolbox po_v1 coll_v1

t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0; 6];

prob = coco_prob();
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'po1', [], 1, {'p1' 'po.period'}, [-1 1]);

bd   = coco_bd_read('po1');
labs = coco_bd_labs(bd, 'all');

figure(1);
clf;
grid on;
hold on;
for lab=labs
  sol = po_read_solution('', 'po1', lab);
  plot3(sol.x(:,1), sol.x(:,2), sol.x(:,3), 'b.-')
end
hold off
drawnow

% we restart at last computed solution with T=1.9553e+01
% find mesh point closest to equilibrium
sol1 = po_read_solution('', 'po1', 6);
f = marsden(sol1.x', repmat(sol1.p, [1 size(sol1.x, 1)]));
[mn idx] = min(sqrt(sum(f.*f, 1)));

% perform surgery on periodic orbit to crank up period,
% po.period -> scale*po.period
scale = 25;
T  = sol1.t(end);
t0 = [sol1.t(1:idx,1) ; T*(scale-1)+sol1.t(idx+1:end,1)];
x0 = sol1.x;
p0 = sol1.p;

% restart with much finer mesh, rule of thumb for uniform mesh of same quality:
%    NTST(new) = scale*NTST(old)
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', ceil(scale*10));
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);

% exchange parameters to fix period and free p2
prob = coco_xchg_pars(prob, 'p2', 'po.period');

% compute family of homoclinic orbits, if not all columns fit, make 'check
% that period is constant an exercise)
coco(prob, 'po2', [], 1, {'p1' 'p2' 'po.period'}, [-1 1]);

coco_use_recipes_toolbox
