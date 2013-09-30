function chap07_fig03
addpath('../Pass_1')
try
  [p0 vs vu] = compute_run_data();
  db = plotdb(1);
  plot_data(db, p0, vs, vu);
  rmpath('../Pass_1')
catch e
  rmpath('../Pass_1')
  rethrow(e);
end
end

function [p0 vs vu] = compute_run_data() %#ok<STOUT>

% run demo
oldpath = path;
if coco_exist('run1', 'run') && coco_exist('run2', 'run') ...
    && coco_exist('run3', 'run') && coco_exist('run4', 'run') ...
    && coco_exist('run5', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);

end

function plot_data(db, p0, vs, vu)
db.plot_create('chap07_fig03', mfilename('fullpath'));
db.paper_size([8 3]);
N     = 20;
x     = linspace(-0.1,1.1,2*N);
y     = linspace(-0.25,0.25,N);
[X Y] = meshgrid(x,y);
fxy   = huxley([X(:) Y(:)]', repmat([0.5;0], [1 numel(X)]));
fx    = reshape(fxy(1,:), size(X));
fy    = reshape(fxy(2,:), size(X));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  template plot with skeleton
% db.quiver(X,Y, fx,fy, 1, 'line2');

plot_skeleton(db, p0, vs, vu, 'line1g3');

db.plot(0.5,0,'line2g5', 'marker5');

db.axis([-0.1 1.1 -0.25 0.25]);
db.xaxis(linspace(0,1,6),2, 0.9, 'y_1');
% db.textbox(0, 0.1, 'y_2', 'tl', 'func');
db.yaxis(linspace(-0.2,0.2,3),2, 0.1, 'y_2');
% db.xlabel([-0.03 -0.025], '\boldmath$y_1$', 'math1');
% db.ylabel([-0.07  0.13], '\boldmath$y_2$', 0, 'math1');
db.plot_margin([0.02 0.03 0.0 0.01]);
% db.plot_margin([0.01 -0.01 0 0]);

db.plot_create_template('huxley_skeleton', mfilename('fullpath'));
db.plot_discard();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  skeleton
db.plot_create('chap07_fig03', mfilename('fullpath'));
db.paper_size([16 6]);
db.quiver(X,Y, fx,fy, 1, 'line1', 'arrow2');

plot_skeleton(db, p0, vs, vu, 'line1');

db.plot(0.5,0,'line2', 'marker5');

db.axis([-0.1 1.1 -0.25 0.25]);
db.xaxis(linspace(0,1,6),2, 0.9, 'y_1');
db.yaxis(linspace(-0.2,0.2,3),2, 0.1, '~~y_2');
db.plot_margin([-0.01 0.02 0.005 0.01]);
db.plot_close();
db.plot_set_bbox('chap07_fig03');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plot for each step
db.plot_create('chap07_fig03a', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run1', 1);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run1', 1);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig03b', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run1', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run1', 5);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig03c', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run2', 2);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run2', 2);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig03d', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run3', 4);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run3', 4);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig03e', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run4', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run4', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

db.plot_create('chap07_fig03f', mfilename('fullpath'));
db.paper_size([8 3]);
db.plot_use_template('huxley_skeleton');

sol = coll_read_solution('huxley1', 'run5', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');
sol = coll_read_solution('huxley2', 'run5', 3);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata');

db.plot_close();

%% align plots
plots = {
  'chap07_fig03a' 'chap07_fig03b'
  'chap07_fig03c' 'chap07_fig03d'
  'chap07_fig03e' 'chap07_fig03f'
  };

db.plot_align_all_axes(plots);

end

function plot_skeleton(db, p0, vs, vu, lstyle)
vs = sign(vs(1))*vs;
vu = sign(vu(1))*vu;

opts = odeset('RelTol', 1.0e-6, 'AbsTol', 1.0e-6, 'NormControl', 'on');

X = linspace(-0.3,0,300);
[t x] = ode45(@(t,x) huxley(x,p0), [0 11.5], -1.0e-4*vu, opts); %#ok<ASGLU>
Y = interp1([0;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)
[t x] = ode45(@(t,x) -huxley(x,p0), [0 11.5], -1.0e-4*vs, opts); %#ok<ASGLU>
Y = interp1([0;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)

X = linspace(0,0.5,500);
[t x] = ode45(@(t,x) huxley(x,p0), [0 13.5], 1.0e-4*vu, opts); %#ok<ASGLU>
Y = interp1([0;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)
[t x] = ode45(@(t,x) -huxley(x,p0), [0 13.5], 1.0e-4*vs, opts); %#ok<ASGLU>
Y = interp1([0;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)

X = linspace(1,1.3,300);
[t x] = ode45(@(t,x) huxley(x,p0), [0 11.5], [1;0]+1.0e-4*vu, opts); %#ok<ASGLU>
Y = interp1([1;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)
[t x] = ode45(@(t,x) -huxley(x,p0), [0 11.5], [1;0]+1.0e-4*vs, opts); %#ok<ASGLU>
Y = interp1([1;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)

X = linspace(0.5,1,500);
[t x] = ode45(@(t,x) huxley(x,p0), [0 13.5], [1;0]-1.0e-4*vu, opts); %#ok<ASGLU>
Y = interp1([1;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)
[t x] = ode45(@(t,x) -huxley(x,p0), [0 13.5], [1;0]-1.0e-4*vs, opts); %#ok<ASGLU>
Y = interp1([1;x(:,1)], [0;x(:,2)], X);
db.plot(X,Y,lstyle)

end
