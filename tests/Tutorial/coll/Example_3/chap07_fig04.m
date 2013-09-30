function chap07_fig04
addpath('../Pass_1')
addpath('../../alg/Pass_8')
try
  [segs algs eps0 th0 vec0 lam0] = compute_run_data();
  compute_extra_data(segs, algs, eps0, th0, vec0, lam0);
  db = plotdb(1);
  plot_data(db);
  rmpath('../../alg/Pass_8')
  rmpath('../Pass_1')
catch e
  rmpath('../../alg/Pass_8')
  rmpath('../Pass_1')
  rethrow(e);
end
end

function [segs algs eps0 th0 vec0 lam0] = compute_run_data() %#ok<STOUT>

% run demo
oldpath = path;
if coco_exist('run1', 'run') && coco_exist('run2', 'run') ...
    && coco_exist('run3', 'run') && coco_exist('run4', 'run') ...
    && coco_exist('run5', 'run') && coco_exist('run6', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);

end

function compute_extra_data(segs, algs, eps0, th0, vec0, lam0)

% high precision runs for skeleton
if ~coco_exist('run1a', 'run')
  prob = coco_prob();
  prob = coco_set(prob, 'coll', 'NTST', 100);
  prob = doedel_isol2het(prob, segs, algs, eps0, th0, vec0, lam0);
  coco(prob, 'run1a', [], 1, 'y12e', [0 0.99]);
end
if ~coco_exist('run2a', 'run')
  prob = coco_prob();
  prob = coco_set(prob, 'cont', 'ItMX', 100);
  prob = doedel_sol2het(prob, 'run1a', 3);
  coco(prob, 'run2a', [], 1, 'y22e', [-0.995 0]);
end
if ~coco_exist('run3a', 'run')
  prob = doedel_sol2het(coco_prob(), 'run2a', 8);
  coco(prob, 'run3a', [], 1, 'gap', [-2 0]);
end
if ~coco_exist('run4a', 'run')
  prob = doedel_sol2het(coco_prob(), 'run3a', 6);
  coco(prob, 'run4a', [], 1, 'eps1', [1e-3 eps0(1)]);
end
if ~coco_exist('run5a', 'run')
  prob = doedel_sol2het(coco_prob(), 'run4a', 3);
  coco(prob, 'run5a', [], 1, 'eps2', [1e-3 eps0(2)]);
end

end

function plot_data(db)
db.plot_create('chap07_fig04', mfilename('fullpath'));
db.paper_size([8 6]);
N     = 30;
alims = [-1.2 1.5 -2 2.2];
x     = linspace(alims(1),alims(2),N);
y     = linspace(alims(3),alims(4),N);
[X Y] = meshgrid(x,y);
fxy   = doedel([X(:) Y(:)]', repmat([1;1], [1 numel(X)]));
fx    = reshape(fxy(1,:), size(X));
fy    = reshape(fxy(2,:), size(X));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  template plot with skeleton
% db.quiver(X,Y, fx,fy, 2, 'line2');

plot_skeleton(db, 'line1g3');

db.axis(alims);
db.xaxis(linspace(-1,1.5,6),2, 1.25, 'y_1');
db.yaxis(linspace(-2,2,5),2, 1.5, '\!\!y_2');
db.plot_margin([0.03 0.02 0.01 0.01]);

db.plot_create_template('doedel_skeleton', mfilename('fullpath'));
db.plot_discard();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  skeleton
db.plot_create('chap07_fig04', mfilename('fullpath'));
db.paper_size([8 6]);
db.quiver(X,Y, fx,fy, 2, 'line1', 'arrow2');

plot_skeleton(db, 'line1');

db.plot(-1,1,'line2', 'marker5');

db.axis(alims);
db.xaxis(linspace(-1,1.5,6),2, 1.25, 'y_1');
db.yaxis(linspace(-2,2,5),2, 1.5, '\!\!y_2');
db.plot_margin([0.03 0.02 0.01 0.01]);
db.plot_close();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot for each step
db.plot_create('chap07_fig04a', mfilename('fullpath'));
db.paper_size([8 6]);
db.plot_use_template('doedel_skeleton');

sol = coll_read_solution('doedel1', 'run1', 1);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('doedel2', 'run1', 1);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig04b', mfilename('fullpath'));
db.paper_size([8 6]);
db.plot_use_template('doedel_skeleton');

sol = coll_read_solution('doedel1', 'run1', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('doedel2', 'run1', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig04c', mfilename('fullpath'));
db.paper_size([8 6]);
db.plot_use_template('doedel_skeleton');

sol = coll_read_solution('doedel1', 'run2', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('doedel2', 'run2', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig04d', mfilename('fullpath'));
db.paper_size([8 6]);
db.plot_use_template('doedel_skeleton');

sol = coll_read_solution('doedel1', 'run3', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('doedel2', 'run3', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig04e', mfilename('fullpath'));
db.paper_size([8 6]);
db.plot_use_template('doedel_skeleton');

sol = coll_read_solution('doedel1', 'run5', 2);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('doedel2', 'run5', 2);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig04f', mfilename('fullpath'));
db.paper_size([8 6]);

bd = coco_bd_read('run6');
labs = coco_bd_labs(bd);
labs = labs(labs<=4 | labs==6 | labs==7 | labs==10);
for lab = labs
  sol = coll_read_solution('doedel1', 'run6', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
  sol = coll_read_solution('doedel2', 'run6', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
  db.textarrow(sol.x(end,1), sol.x(end,2), 1, sprintf('%d', lab), 'tr', 'lab');
end

db.axis(alims);
db.xaxis(linspace(-1,1.5,6),2, 1.25, 'y_1');
db.yaxis(linspace(-2,2,5),2, 1.5, '\!\!y_2');
db.plot_margin([0.03 0.02 0.01 0.01]);
db.plot_close();

%% align plots
plots = {
  'chap07_fig04'  'chap07_fig04a'
  'chap07_fig04b' 'chap07_fig04c'
  'chap07_fig04e' 'chap07_fig04f'
  };

db.plot_align_all_axes(plots);

end

function plot_skeleton(db, lstyle)
v1 = [-3/sqrt(10); 1/sqrt(10)];
[t x] = ode45(@(t,x) -doedel(x,[1;1]), [0 4.2], [1;-1]-1.0e-4*v1); %#ok<ASGLU>
db.plot(x(:,1), x(:,2), lstyle)
sol = coll_read_solution('doedel1', 'run5a', 3);
db.plot([-1 ; sol.x(:,1)], [1 ; sol.x(:,2)], lstyle);
sol = coll_read_solution('doedel2', 'run5a', 3);
db.plot([sol.x(:,1);x(1,1)], [sol.x(:,2);x(1,2)], lstyle);
db.plot([1 1], [-3 3], lstyle);
end
