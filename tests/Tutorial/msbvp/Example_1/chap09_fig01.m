function chap09_fig01
oldpath = path;
addpath('../../coll/Pass_1')
addpath('..')
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  path(oldpath);
catch e
  path(oldpath);
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~coco_exist('run0', 'run')
  oldpath = path;
  run demo_without_plots
  path(oldpath);
end
end

function plot_data(db)

db.plot_create('chap09_fig01b', mfilename('fullpath'));
db.box('off');
plot_torus(db, 'run0', 1);
db.axis([-1.5 1.5 -2 2 -0.5 2]);
db.view([50 15]);

db.xaxis(linspace(-1.5,1.5,7), [-1 0 1], [-0.2 -3 -0.8], 'y_1');
db.yaxis(linspace(-2,2,5),2, [1.5 1.5 -1], 'y_2');
zticks = linspace(-0.5,2,6);
zlabs  = [0 1 2];
db.zaxis(zticks,zlabs, [-1.5 -2.8 1.5], 'y_3');
db.plot_margin([0.07 0.00 0.02 0.00]);
db.plot_close();

db.plot_set_bbox('chap09_fig01b');
end

function [sol data] = plot_torus(db, run, lab, fac)

if nargin<4
  fac=1;
end

[sol data] = msbvp_read_solution('', run, lab);
N  = data.nsegs;
M  = ceil(fac*size(sol{1}.x,1));
x0 = zeros(N+1,3);
x1 = zeros(N+1,3);
XX = zeros(M,N+1);
YY = XX;
ZZ = XX;
for i=1:N+1
  n       = mod(i-1,N)+1;
  XX(:,i) = sol{n}.x(1:M,1);
  YY(:,i) = sol{n}.x(1:M,2);
  ZZ(:,i) = sol{n}.x(1:M,3);
  x0(i,:) = sol{n}.x(1,:);
  x1(i,:) = sol{n}.x(M,:);
end
db.surf(XX, YY, ZZ, 'FaceColor', 0.9*[1 1 1], 'FaceAlpha', 0.7, ...
  'MeshStyle', 'column', 'LineStyle', '-', 'EdgeColor', 0.6*[1 1 1], ...
  'LineWidth', 0.5);
db.plot(x0(:,1), x0(:,2), x0(:,3), 'numdata');
db.plot(sol{30}.x(:,1), sol{30}.x(:,2), sol{30}.x(:,3), 'line1');

end
