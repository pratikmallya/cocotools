% Demo of moving mesh adaptation methods.
%
% This is a repetition of the computation of a homoclinic curve in
% po/Examples_3 with adaptive collocation codes. The demo proceeds
% in three steps:
%   1. Start at Hopf point and continue until homoclinic orbit is close.
%   2. Perform surgery to obtain initial guess for high-period orbit.
%   2. Iterate the remeshing map a number of times.
% The demo is executed three times, once for each adaptation method.

%% Run with moving mesh fixed order
echo on
addpath('../Pass_3', '../../po');
%!tkn1
t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0;6];
%!tkn2
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', 50);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'run1', [], 1, {'p1' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'}, [-1 1]);
%!tkn3

% find mesh point closest to equilibrium
%!tkn4
sol1 = po_read_solution('', 'run1', 6);
f = marsden(sol1.x', repmat(sol1.p, [1 size(sol1.x,1)]));
[mn idx] = min(sqrt(sum(f.*f,1)));
%!tkn5
% perform surgery on periodic orbit to crank up period,
% po.period -> scale*po.period
%!tkn6
scale = 25;
T     = sol1.t(end);
t0 = [sol1.t(1:idx,1) ; T*(scale-1)+sol1.t(idx+1:end,1)];
x0 = sol1.x;
p0 = sol1.p;
%!tkn7
% restart with much finer mesh, rule of thumb for uniform mesh of same quality:
%    NTST(new) = scale*NTST(old)
%!tkn8
prob = coco_prob();
prob = coco_set(prob, 'coll', 'NTST', ceil(scale*50));
prob = coco_set(prob, 'coll', 'TOL', 1.0e-1);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
%!tkn9
% exchange parameters to fix period and free p2, iterate adaptation map
prob = coco_xchg_pars(prob, 'p2', 'po.period');
coco(prob, 'run2', [], 0, {'p1' 'p2' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'});

% compare solutions before and after surgery
figure(2)
clf
hold on
sol = po_read_solution('', 'run1', 6);
plot(sol.x(:,1), sol.x(:,2), 'b.-')
sol = po_read_solution('', 'run2', 1);
plot(sol.x(:,1), sol.x(:,2), 'g.-')
% plot(sol.t, sol.x, 'g.-')
hold off

echo off
rmpath('../Pass_3', '../../po');


%% Run with moving mesh fixed order
echo on
addpath('../Pass_4', '../../po/adapt');
%!tkn1
t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0;6];
%!tkn2
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1);
prob = coco_set(prob, 'coll', 'NTST', 20);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'run1a', [], 1, {'p1' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'}, [-1 1]);
%!tkn3

% find mesh point closest to equilibrium
%!tkn4
sol1 = po_read_solution('', 'run1a', 6);
f = marsden(sol1.x', repmat(sol1.p, [1 size(sol1.x,1)]));
[mn idx] = min(sqrt(sum(f.*f,1)));
%!tkn5
% perform surgery on periodic orbit to crank up period,
% po.period -> (fac*NTSTINC)*po.period
% note that reproduction of initial mesh in coll constructor is exploited
% here to obtain a reasonable first solution point, our surgery inserts
% exactly NTSTINC mesh intervals such that the mesh of the excursion from
% the equilibrium remains unchanged (interpolation would introduce large
% errors), note also that the new period obtained here is significantly
% larger than in po/Examples_3
% we assume NCOL = 4
%!tkn6
fac     = 50;
NTSTINC = 100;
NTST    = (numel(sol1.t)-1)/4;
PTINC   = NTSTINC*4+2;
T       = sol1.t(end);
scale   = fac*NTSTINC;
ti = linspace(sol1.t(idx,1), T*(scale-1)+sol1.t(idx+1,1), PTINC);
xi = zeros(PTINC,3);
for i=1:3
  xi(:,i) = linspace(sol1.x(idx,i), sol1.x(idx+1,i), PTINC);
end
t0 = [sol1.t(1:idx-1,1) ; ti' ; T*(scale-1)+sol1.t(idx+2:end,1)];
x0 = [sol1.x(1:idx-1,:) ; xi ; sol1.x(idx+2:end,:)];
p0 = sol1.p;
%!tkn7
% construct periodic orbit problem and set options to execution of 100
% remeshing cycles with atlas_0d, 100 cycles seems a good choice
% for plot of dynamics of adaptation map use
%   bd = coco_bd_read('run2a');
%   plot(coco_bd_col(bd,'PT'), coco_bd_col(bd,'po.seg.coll.err'))
% important detail: set TOL to something high --> MXCL does not occur
% while we obtain good mesh
%!tkn8
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 100);
prob = coco_set(prob, 'coll', 'NTST', NTST+NTSTINC);
prob = coco_set(prob, 'coll', 'TOL', 1.0e-1);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
%!tkn9
% exchange parameters to fix period and free p2, iterate adaptation map
prob = coco_xchg_pars(prob, 'p2', 'po.period');
coco(prob, 'run2a', [], 0, {'p1' 'p2' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'});

% compare solutions before and after surgery
figure(2)
clf
hold on
sol = po_read_solution('', 'run1a', 6);
plot(sol.x(:,1), sol.x(:,2), 'b.-')
sol = po_read_solution('', 'run2a', 4);
plot(sol.x(:,1), sol.x(:,2), 'g.-')
% plot(sol.t, sol.x, 'g.-')
hold off

echo off
rmpath('../Pass_4', '../../po/adapt');


%% Run with moving mesh adaptive order
echo on
addpath('../Pass_5', '../../po/adapt');
%!tkn1
t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0;6];
%!tkn2
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'run1b', [], 1, {'p1' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'}, [-1 1]);
%!tkn3

% find mesh point closest to equilibrium
%!tkn4
sol1 = po_read_solution('', 'run1b', 6);
f = marsden(sol1.x', repmat(sol1.p, [1 size(sol1.x,1)]));
[mn idx] = min(sqrt(sum(f.*f,1)));
%!tkn5
% perform surgery on periodic orbit to crank up period,
% po.period -> (fac*NTSTINC)*po.period
% note that reproduction of initial mesh in coll constructor is exploited
% here to obtain a reasonable first solution point, our surgery inserts
% exactly NTSTINC mesh intervals such that the mesh of the excursion from
% the equilibrium remains unchanged (interpolation would introduce large
% errors), note also that the new period obtained here is significantly
% larger than in po/Examples_3
% we assume NCOL = 4
%!tkn6
fac     = 50;
NTSTINC = 100;
NTST    = (numel(sol1.t)-1)/4;
PTINC   = NTSTINC*4+2;
T       = sol1.t(end);
scale   = fac*NTSTINC;
ti = linspace(sol1.t(idx,1), T*(scale-1)+sol1.t(idx+1,1), PTINC);
xi = zeros(PTINC,3);
for i=1:3
  xi(:,i) = linspace(sol1.x(idx,i), sol1.x(idx+1,i), PTINC);
end
t0 = [sol1.t(1:idx-1,1) ; ti' ; T*(scale-1)+sol1.t(idx+2:end,1)];
x0 = [sol1.x(1:idx-1,:) ; xi ; sol1.x(idx+2:end,:)];
p0 = sol1.p;
%!tkn7
% construct periodic orbit problem and set options to execution of 100
% remeshing cycles with atlas_0d, 100 cycles seems a good choice
% for plot of dynamics of adaptation map use
%   bd = coco_bd_read('run2b');
%   plot(coco_bd_col(bd,'PT'), coco_bd_col(bd,'po.seg.coll.err'))
%   plot(coco_bd_col(bd,'PT'), coco_bd_col(bd,'po.seg.coll.NTST'))
% important detail: set TOL to something high while TOLINC and TOLDEC are
% set to values that force appropriate re-meshing --> MXCL does not occur
% while we obtain good mesh
%!tkn8
prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 100);
prob = coco_set(prob, 'coll', 'NTST', NTST+NTSTINC, 'NTSTMX', 200);
prob = coco_set(prob, 'coll', 'TOL', 1.0e-1, 'TOLINC', 5.0e-5, 'TOLDEC', 1.0e-5);
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
%!tkn9
% exchange parameters to fix period and free p2, iterate adaptation map
prob = coco_xchg_pars(prob, 'p2', 'po.period');
coco(prob, 'run2b', [], 0, {'p1' 'p2' 'po.period' 'po.seg.coll.NTST' 'po.seg.coll.err'});

% compare solutions before and after surgery
hold on
sol = po_read_solution('', 'run1b', 6);
plot(sol.x(:,1), sol.x(:,2), 'b.-')
sol = po_read_solution('', 'run2b', 4);
plot(sol.x(:,1), sol.x(:,2), 'g.-')
% plot(sol.t, sol.x, 'g.-')
hold off

echo off
rmpath('../Pass_5', '../../po/adapt');

