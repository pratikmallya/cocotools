% Impoprtant: I fixed a bug in varcoll/Pass_2. The initialisation of the
% initial solution vector was missing. This lead to a ridiculous residuum in
% step 8 below. This might affect a number of outputs.
%
% - changed normal vector to make lin-plane clearly separate the po and the
%   ep (previous plane did intersect the po), it is now obvious that any
%   connecting orbit must cross this plane
% - made the normal vector and base point of the lin hyperplane part of the
%   toolbox data
% - split lingap into lingap and linphase, these really shouldn't be mixed
%   up
% - linphase now uses a proper phase condition that doesn't have the
%   artificial dependence on the normal vector of the lin hyperplane, in
%   general, the phase vector would need updating
% - moved construction of riess system including lin gap to riess_[re]start2

echo on
addpath('../');
addpath('../../../po');
addpath('../../../coll/Pass_2')
%% Step 1:
% Continue periodic orbit from Hopf bifurcation
%!tkn1
s  = 10;
b  = 8/3;
r  = 470/19;
p0 = [s; r; b];
eq = [-sqrt(b*(r-1)) -sqrt(b*(r-1)) r-1];
om = 4*sqrt(110/19);
re = [-20/9*sqrt(38/1353) 2/9*sqrt(38/1353) 1];
im = [-19/9*sqrt(5/123) -35/9*sqrt(5/123) 0];
t0 = (0:2*pi/100:2*pi)'/om;
x0 = repmat(eq, size(t0))+0.01*(cos(om*t0)*re-sin(om*t0)*im);
coll_args = {@lorentz, @lorentz_DFDX, @lorentz_DFDP, t0, x0, ...
  {'s' 'r' 'b'}, p0};
var_args = {@lorentz_DFDXDX, @lorentz_DFDXDP};
prob = povar_isol2orb(coco_prob(), '', coll_args{:}, var_args{:});
coco(prob, 'runHopf', [], 1, 'r', [24 25]);
%!tkn2
%% Step 2:
% Grow orbit in unstable manifold of equilibrium
%!tkn3
prob = riess_start_1(coco_prob(), 'runHopf', 6);
prob = coco_set(prob, 'cont', 'ItMX', 500);
prob = coco_set(prob, 'cont', 'NPR', 50);
cont_args = {{'sg1' 'T1'  'T2'}, {[-30 0] [0 1]}};
coco(prob, 'run1', [], 1, cont_args{:});
%!tkn4
%% Step 5:
% Grow orbit in stable manifold of periodic orbit
%!tkn5
prob = riess_restart_1(coco_prob(), 'run1', 6);
prob = coco_set(prob, 'cont', 'ItMX', 500);
prob = coco_set(prob, 'cont', 'NPR', 50);
cont_args = {{'sg2' 'T2' 'T1'}, {[0 30] [0 1]}};
coco(prob, 'run2', [], 1, cont_args{:});
%!tkn6
%% Step 6:
% Sweep family of orbits in stable manifold of periodic orbit
%!tkn7
prob = riess_restart_1(coco_prob(), 'run2', 9);
prob = coco_set(prob, 'cont', 'ItMX', 300);
cont_args = {{'eps2' 'T1' 'T2'}, [1e-6 1e-1]};
coco(prob, 'run3', [], 1, cont_args{:});
%!tkn8
% moved to riess_restart2
%!tkn9
%% Step 7:
% Pick orbit in stable manifold of periodic orbit with smallest
% distance in section, fix end point to line through end points
% and shrink gap along line through end points
%!tkn10
prob = riess_start_2(coco_prob(), 'run3');
prob = coco_set(prob, 'cont', 'ItMX', 500);
cont_args = {{'lingap' 'r' 'eps2' 'T1' 'T2'}, [-1 0]};
coco(prob, 'run4', [], 1, cont_args{:});
%!tkn12
%% Step 8:
% Continue in parameters
%!tkn13
prob = riess_restart_2(coco_prob(), 'run4', 7);
prob = coco_set(prob, 'cont', 'ItMX', 500);
prob = coco_set(prob, 'cont', 'NPR', 50);
cont_args = {{'r' 'b' 'eps1' 'eps2' 'T2'}, [20 30]};
coco(prob, 'run5', [], 1, cont_args{:});
%!tkn14
%% Plot result
bd5  = coco_bd_read('run5');
labs = coco_bd_labs(bd5, 'ALL');
clf
hold on
for lab=labs
  sol = coll_read_solution('col1', 'run5', lab);
  plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'r')
  sol = coll_read_solution('col2', 'run5', lab);
  plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'b')
  sol = coll_read_solution('po.seg', 'run5', lab);
  plot3(sol.x(:,1),sol.x(:,2),sol.x(:,3),'g')
end
hold off
%%
rmpath('../');
rmpath('../../../po');
rmpath('../../../coll/Pass_2')
echo off