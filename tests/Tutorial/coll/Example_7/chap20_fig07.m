function chap20_fig07
oldpath = path;
addpath('../Pass_3', '../../po');
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  % plot_second(db);
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
if ~(coco_exist('run1', 'run') && coco_exist('run2', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

sol0 = po_read_solution('', 'run1', 6); % NTST=50, err=4.2532e-05
sol1 = po_read_solution('', 'run2', 1); % NTST=1250, err=4.2531e-05, T=4.6378e+02

idx1 = 1:4:50*4+1;
idx2 = 1:4:1250*4+1;

db.plot_create('chap20_fig07a', mfilename('fullpath'));
db.plot(sol0.x(:,1), sol0.x(:,2), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,1), sol0.x(idx1,2), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata')
db.plot(sol1.x(idx2,1), sol1.x(idx2,2), 'numdata', 'none1', 'marker1l')
db.axis([-0.3 0.25 -0.5 0.1]);
db.xaxis(-0.4:0.1:0.3,2, 0.22,'y_1');
db.yaxis(-0.5:0.1:0.1,2, 0.04,'\!y_2');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();

db.plot_create('chap20_fig07b', mfilename('fullpath'));
db.plot(sol0.x(:,2), sol0.x(:,3), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,2), sol0.x(idx1,3), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,2), sol1.x(:,3), 'numdata')
db.plot(sol1.x(idx2,2), sol1.x(idx2,3), 'numdata', 'none1', 'marker1l')
db.axis([-0.5 0.1 -0.1 0.8]);
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.7,'\!y_3');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();

end

function plot_second(db)

sol1 = po_read_solution('', 'run2', 1); % NTST=1250, err=4.2531e-05, T=4.6378e+02

N   = numel(sol1.t);
N2  = round(N/2);
idx = [N2:N 2:N2];
tt  = [sol1.t(N2:N)-sol1.t(N2) ; sol1.t(N)+sol1.t(2:N2)-sol1.t(N2)];
tt  = tt/tt(end);
idx2 = 1:4:1250*4+1;

db.plot_create('chap20_fig07c', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 1 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(2000), sol1.x(2000,1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(2000), sol1.x(2000,2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(2000), sol1.x(2000,3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 0 0.01]);
db.plot_close();



db.plot_create('chap20_fig07d', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0.45 0.55 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(2400), sol1.x(2400,1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(2400), sol1.x(2400,2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(2400), sol1.x(2400,3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0.45:0.01:0.55, 2, 0.543, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 0 0.01]);
db.plot_close();

db.plot_align_all_axes({'chap20_fig07a' 'chap20_fig07b'});

db.plot_align_all_axes({
  'chap20_fig07c'
  'chap20_fig07d'
  });

end
