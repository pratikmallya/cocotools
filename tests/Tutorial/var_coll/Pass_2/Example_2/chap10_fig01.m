function chap10_fig01
oldpath = path;
addpath('../../../coll/Pass_2')
addpath('../../../po');
addpath('..');
try
  compute_run_data();
  db = plotdb(1);
  % plot_first(db);
  plot_second(db);
  % plot_third(db);
  path(oldpath)
  coco_clear_cache('reset');
catch e
  path(oldpath)
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~(coco_exist('runHopf', 'run') && coco_exist('run1', 'run') ...
    && coco_exist('run2', 'run') && coco_exist('run3', 'run') ...
    && coco_exist('run4', 'run') && coco_exist('run5', 'run')) 
  oldpath = path;
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
  run demo
  path(oldpath);
end
end

function plot_first(db)

s  = 10;
b  = 8/3;

db.plot_create('chap10_fig01a', mfilename('fullpath'));
db.axis([-10 10 -10 10 0 15]);
db.view([30 30]);
db.box('off');

r  = 10;
vu = [1-s+sqrt((1-s)^2 + 4*r*s) ; -2*r ; 0 ];
vu = vu/norm(vu);
x0 = 0.001*vu;
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 10], x0); %#ok<ASGLU>
[t x2] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 10], -x0); %#ok<ASGLU>

db.plot(x1(:,1), x1(:,2), x1(:,3), 'line2');
db.plot(x2(:,1), x2(:,2), x2(:,3), 'line2');
db.plot(0,0,0, 'line1', 'marker6l');

db.xaxis(linspace(-10,10,5),2, [-5 -15 -2.5], 'y_1');
db.yaxis(linspace(-10,10,5),2, [15 0 -2.5], 'y_2');
db.zaxis(linspace(0,15,4),2, [-14 -10 11], 'y_3');
db.plot_margin([0.05 0 0.02 0]);
db.plot_close();

db.plot_create('chap10_fig01b', mfilename('fullpath'));
db.axis([-18 18 -25 25 0 40]);
db.view([30 30]);
db.box('off');

r  = 24;
vu = [1-s+sqrt((1-s)^2 + 4*r*s) ; -2*r ; 0 ];
vu = vu/norm(vu);
x0 = 0.001*vu;
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 20], x0); %#ok<ASGLU>
[t x2] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 20], -x0); %#ok<ASGLU>

db.plot(x1(:,1), x1(:,2), x1(:,3), 'line2');
db.plot(x2(:,1), x2(:,2), x2(:,3), 'line2');
db.plot(0,0,0, 'line1', 'marker6l');

db.xaxis(linspace(-20,20,9),1, [-10 -35 -8], 'y_1');
db.yaxis(linspace(-30,30,7),1, [25 0 -5], 'y_2');
db.zaxis(linspace(0,40,5),2, [-21 -35 37], 'y_3');
%db.plot_margin([0.05 0 0.02 0]);
db.plot_close();

plots = {'chap10_fig01a' 'chap10_fig01b'};
db.plot_align_all_axes(plots);

end

function plot_second(db)

s  = 10;
b  = 8/3;

db.plot_create('chap10_fig02a', mfilename('fullpath'));
db.paper_size([5.3 4]);
db.axis([-12 3 -14 -2 16 31]);
db.view([24 18]);
db.box('off');

r  = 23;
vu = [1-s+sqrt((1-s)^2 + 4*r*s) ; -2*r ; 0 ];
vu = vu/norm(vu);
x0 = 0.001*vu;
opts = odeset('MaxStep', 0.05);
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 1.4], -x0); %#ok<ASGLU>
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 20], x1(end,:), opts); %#ok<ASGLU>

db.plot(x1(:,1), x1(:,2), x1(:,3), 'line3');

db.xaxis([-12 -8 -4 0 3],[-12 -8 -4 0], [-8 -18 13.5], 'y_1');
db.yaxis(linspace(-16,0,5),1, [5 -6 12.5], 'y_2');
db.zaxis(linspace(16,31,4),2, [-14.5 -17 29.5], 'y_3');
db.plot_margin([0.06 0.04 0.05 0]);
db.plot_close();



db.plot_create('chap10_fig02b', mfilename('fullpath'));
db.paper_size([5.3 4]);
db.axis([-12 3 -14 -2 16 31]);
db.view([24 18]);
db.box('off');

r  = 24;
vu = [1-s+sqrt((1-s)^2 + 4*r*s) ; -2*r ; 0 ];
vu = vu/norm(vu);
x0 = 0.001*vu;
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 1.4], -x0); %#ok<ASGLU>
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 20], x1(end,:), opts); %#ok<ASGLU>

db.plot(x1(:,1), x1(:,2), x1(:,3), 'line3');

db.xaxis([-12 -8 -4 0 3],[-12 -8 -4 0], [-8 -18 13.5], 'y_1');
db.yaxis(linspace(-16,0,5),1, [5 -6 12.5], 'y_2');
db.zaxis(linspace(16,31,4),2, [-14.5 -17 29.5], 'y_3');
db.plot_margin([0.06 0.04 0.05 0]);
db.plot_close();



db.plot_create('chap10_fig02c', mfilename('fullpath'));
db.paper_size([5.3 4]);
db.axis([-12 3 -14 -2 16 31]);
db.view([24 18]);
db.box('off');

r  = 25;
vu = [1-s+sqrt((1-s)^2 + 4*r*s) ; -2*r ; 0 ];
vu = vu/norm(vu);
x0 = 0.001*vu;
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 1.3], -x0); %#ok<ASGLU>
[t x1] = ode45(@(t,x) lorentz(x,[s;r;b]), [0 20], x1(end,:), opts); %#ok<ASGLU>

db.plot(x1(:,1), x1(:,2), x1(:,3), 'line3');

db.xaxis([-12 -8 -4 0 3],[-12 -8 -4 0], [-8 -18 13.5], 'y_1');
db.yaxis(linspace(-16,0,5),1, [5 -6 12.5], 'y_2');
db.zaxis(linspace(16,31,4),2, [-14.5 -17 29.5], 'y_3');
db.plot_margin([0.06 0.04 0.05 0]);
db.plot_close();

plots = {'chap10_fig02a' 'chap10_fig02b' 'chap10_fig02c'};
db.plot_align_all_axes(plots);

end

function plot_third(db)

runs  = {'run1' 'run1' 'run2' 'run4'};
labs  = [1 6 9 8];
suffs = 'abcf';
plots = {};

for i=1:numel(runs)
  run   = runs{i};
  lab   = labs(i);
  suff  = suffs(i);
  plot  = sprintf('chap10_fig03%c', suff);
  plots = [ plots { plot } ]; %#ok<AGROW>
  
  db.plot_create(plot, mfilename('fullpath'));
  db.axis([-10 40 -20 30 -10 40]);
  db.view([35 25]);
  db.box('off');
  db.camproj('perspective');
  
  sol = coll_read_solution('po.seg', run, lab);
  db.plot(sol.x(:,1),sol.x(:,2),sol.x(:,3), 'numdata', 'line1g4')
  sol = coll_read_solution('col1', run, lab);
  db.plot(sol.x(:,1),sol.x(:,2),sol.x(:,3), 'numdata')
  sol = coll_read_solution('col2', run, lab);
  db.plot(sol.x(:,1),sol.x(:,2),sol.x(:,3), 'numdata')
  
  [X Y] = meshgrid([-10 40], [-20 30]);
  Z     = @(n,x0, x,y) (x0'*n)/n(3) - (n(1)/n(3))*x - (n(2)/n(3))*y;
  n     = [0;-1;1];
  x0    = [20;20;30];
  db.surf(X,Y,Z(n,x0,X,Y), 'facecolor', 0.5*[1 1 1], 'facealpha', ...
    0.5, 'linestyle', '-');
  
  db.xaxis(-10:10:40,0:10:40, [0 -20 -25], 'y_1');
  db.yaxis(-20:10:30,-20:10:30, [40 20 -25], 'y_2');
  db.zaxis(-10:10:40,[0 20 40], [-15 -25 30], 'y_3');
  db.plot_margin([0.04 0.02 0.01 0]);
  db.plot_close();
end

XX = [];
YY = [];
ZZ = [];

bd = coco_bd_read('run3');
for lab = coco_bd_labs(bd)
  sol = coll_read_solution('col2', 'run3', lab);
  XX = [XX sol.x(:,1)]; %#ok<AGROW>
  YY = [YY sol.x(:,2)]; %#ok<AGROW>
  ZZ = [ZZ sol.x(:,3)]; %#ok<AGROW>
end

db.plot_create('chap10_fig03d', mfilename('fullpath'));
plots = [ plots {'chap10_fig03d'} ];
db.axis([-10 40 -20 30 -10 40]);
db.view([35 25]);
db.box('off');
db.camproj('perspective');

sol = coll_read_solution('po.seg', 'run3', 1);
db.plot(sol.x(:,1),sol.x(:,2),sol.x(:,3), 'numdata', 'line1g4')
sol = coll_read_solution('col1', 'run3', 1);
db.plot(sol.x(:,1),sol.x(:,2),sol.x(:,3), 'numdata')

db.surf(XX,YY,ZZ, 'FaceColor', 0.9*[1 1 1], 'FaceAlpha', 1, ...
  'MeshStyle', 'column', 'LineStyle', '-', 'EdgeColor', 0.6*[1 1 1], ...
  'LineWidth', 0.5);

db.plot(XX(1,:), YY(1,:), ZZ(1,:), 'line1w');

db.plot_create_template('riess', mfilename('fullpath'));

[X Y] = meshgrid([-10 40], [-20 30]);
Z = @(n,x0, x,y) (x0'*n)/n(3) - (n(1)/n(3))*x - (n(2)/n(3))*y;
n = [0;-3;3];
x0 = [20;20;30];
db.surf(X,Y,Z(n,x0,X,Y), 'facecolor', 0.5*[1 1 1], 'facealpha', 0.5, ...
  'linestyle', '-');
  
db.xaxis(-10:10:40,0:10:40, [0 -20 -25], 'y_1');
db.yaxis(-20:10:30,-20:10:30, [40 20 -25], 'y_2');
db.zaxis(-10:10:40,[0 20 40], [-15 -25 30], 'y_3');
db.plot_margin([0.04 0.02 0.01 0]);

db.plot_close();

db.plot_create('chap10_fig03e', mfilename('fullpath'));
plots = [ plots {'chap10_fig03e'} ];
db.plot_use_template('riess');

db.axis([-10 40 -13 32 0 50]);
db.view([-135 -10]);

[X Y] = meshgrid([0 40], [18 32]);
Z     = @(n,x0, x,y) (x0'*n)/n(3) - (n(1)/n(3))*x - (n(2)/n(3))*y;
n     = [0;-3;3];
x0    = [20;20;30];
db.surf(X,Y,Z(n,x0,X,Y), 'facecolor', 0.5*[1 1 1], 'facealpha', 0.5, ...
  'linestyle', '-');

db.xaxis(-10:10:30,-10:10:30, [10 -13 -8], 'y_1');
db.yaxis([-13 -10:10:30 32],-10:10:30, [40 20 -8], 'y_2');
db.zaxis(0:10:50,[10 30 50], [40 42 40], 'y_3');
db.plot_margin([0.05 0.04 0.01 0]);

db.plot_close();

db.plot_align_all_axes(plots);

end
