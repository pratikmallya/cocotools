echo on
%!tkn1
eps0 = 0.1;
t0 = linspace(0, 2*pi, 100)';
x0 = [sin(t0) cos(t0)];
prob = coco_set(coco_prob(), 'cont', 'ItMX', 100);
prob = coco_set(prob, 'dft', 'TOL', 1e-3);
prob2 = coco_set(prob, 'dft', 'NMAX', 250, 'NMOD', 20);
prob2 = dft_isol2orb(prob2, '', @pneta, t0, x0, 'eps', eps0);
coco(prob2, 'run1', [], 1, {'eps' 'dft.err' 'dft.NMOD'}, [0.1 20]);
bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'EP');
prob2 = dft_sol2orb(prob, '', 'run1', lab(end));
coco(prob2, 'run2', [], 1, {'eps' 'dft.err' 'dft.NMOD'}, [0.1 20]);
%!tkn2
echo off
figure(1)
clf

bd = coco_bd_read('run1');
ep = coco_bd_col(bd, 'eps');
er = coco_bd_col(bd, 'dft.err');
nm = coco_bd_col(bd, 'dft.NMOD');
subplot(2,2,1);
plot(ep,er, '.-');
grid on
subplot(2,2,3);
plot(ep,nm, '.-');
grid on

bd = coco_bd_read('run2');
ep = coco_bd_col(bd, 'eps');
er = coco_bd_col(bd, 'dft.err');
nm = coco_bd_col(bd, 'dft.NMOD');
subplot(2,2,2);
plot(ep,er, '.-');
grid on
subplot(2,2,4);
plot(ep,nm, '.-');
grid on

% hold on
% for lab=labs
%   sol = dft_read_solution('', 'run', lab);
%   plot(sol.x(:,1),sol.x(:,2),'r.-')
% end
% hold off

return
%% demo with forced, damped, harmonic oscillator

p0 = 1;
t0 = (0:2*pi/100:2*pi)';
z0 = [sin(t0) cos(t0) sin(t0) cos(t0)];
prob = coco_prob();
prob = coco_set(prob, 'dft', 'NMAX', 100, 'NMOD', 1);
prob = dft_isol2orb(prob, '', @linearode, t0, z0, 'k', p0);

coco(prob, 'run', [], 1, {'k' 'err' 'NMOD'}, [0.5 2]);
sol = dft_read_solution('', 'run', 5);
plot(sol.x(:,1),sol.x(:,2),'r.-')

%% demo with autonomous chemical oscillator

p0 = [0.1631021 1250 0.046875 20 1.104 0.001 3 0.6 0.1175]';
x0 = [25 1.45468 0.01524586 0.1776113]';
f  = @(t,x) chemosz(x,p0);

[~, z] = ode15s(f, [0 800], x0);
x0    = z(end,:)';
[t0 z0] = ode15s(f, [0 13.4], x0);

prob = coco_prob();
prob = coco_set(prob, 'dft', 'TOL', 1e-2);
prob = coco_set(prob, 'cont', 'ItMX', 200);
prob = coco_set(prob, 'dft', 'NMAX', 200, 'NMOD', 11);
prob = dft_isol2orb(prob,'',@chemosz, t0, z0, ...
  {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'} , p0);
coco(prob, 'run1', [], 1, {'a' 'err' 'NMOD'}, [0.1 0.2]);
bd = coco_bd_read('run1');
labs = coco_bd_labs(bd, 'all');
figure(100)
clf
hold on
for lab=labs
sol = dft_read_solution('', 'run1', lab);
plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'r.-')
end

prob = coco_prob();
prob = coco_set(prob, 'dft', 'NMAX', 200)
prob = dft_sol2orb(prob, '', 'run', 5);
coco(prob, 'run2', [], 1, {'g' 'NMOD'}, [2 4]);
bd = coco_bd_read('run2');
labs = coco_bd_labs(bd, 'all');
for lab=labs
sol = dft_read_solution('', 'run', lab);
plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'k.-')
end