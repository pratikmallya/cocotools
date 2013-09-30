function chap09_fig02
oldpath = path;
addpath('../../coll/Pass_1')
addpath('..')
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  path(oldpath);
  coco_clear_cache('reset');
catch e
  path(oldpath);
  coco_clear_cache('reset');
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

bd   = coco_bd_read('run1');
labs = [6 4 1 10 12];

db.plot_create('chap09_fig02a', mfilename('fullpath'));
db.axis([0.37 0.4 -0.05 0.05]);

eps = coco_bd_col(bd, 'eps');
ro  = coco_bd_col(bd, 'ro');
db.plot(ro, eps, 'numdata');
for lab=labs
  eps = coco_bd_val(bd,lab,'eps');
  ro  = coco_bd_val(bd,lab,'ro');
  if lab == 1
    db.textarrow(ro, eps, 1, sprintf('%d', lab), 'r', 'lab');
  elseif lab >= 10
    db.textarrow(ro, eps, 1, sprintf('%d', lab), 'br', 'lab');
  else
    db.textarrow(ro, eps, 1, sprintf('%d', lab), 'tr', 'lab');
  end
end
db.xaxis(linspace(0.37,0.4,4),4, 0.3975, '\rho');
db.yaxis(linspace(-0.04,0.04, 5),2, 0.046,'\varepsilon');
db.plot_margin([0.01 0.02 0 0.005]);
db.plot_close();

suff  = 'b';
plots = {'chap09_fig02a'};

for lab = labs
  plot = sprintf('chap09_fig02%c', suff);
%   db.plot_create(plot, mfilename('fullpath'));
%   db.box('off');
%   plot_torus(db, 'run1', lab);
%   db.axis([-1.5 1.5 -2 2 -0.5 2]);
%   db.view([50 15]);
%   db.textarrow(0.69, 0.72, 1, sprintf('%d', lab), 'tr', 'lab');
%   
%   db.xaxis(linspace(-1.5,1.5,7), [-1 0 1], [-0.2 -3 -0.8], 'y_1');
%   db.yaxis(linspace(-2,2,5),2, [1.5 1.5 -1], 'y_2');
%   zticks = linspace(-0.5,2,6);
%   zlabs  = [0 1 2];
%   db.zaxis(zticks,zlabs, [-1.5 -2.8 1.5], 'y_3');
%   db.plot_margin([0.07 0.00 0.02 0.00]);
%   db.plot_close();
  plots = [ plots { plot } ]; %#ok<AGROW>
  suff = char(suff + 1);
end

db.plot_align_all_axes(plots);

end

function [sol data] = plot_torus(db, run, lab, fac)

if nargin<4
  fac=0.75;
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
db.plot(x1(:,1), x1(:,2), x1(:,3), 'numdata');

end
