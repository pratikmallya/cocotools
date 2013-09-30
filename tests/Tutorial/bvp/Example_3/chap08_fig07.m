function chap08_fig07
addpath('../../coll/Pass_1')
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  rmpath('../../coll/Pass_1')
catch e
  rmpath('../../coll/Pass_1')
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~coco_exist('run_moving', 'run') || ~coco_exist('run_fixed', 'run')
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

db.plot_create('chap08_fig07a', mfilename('fullpath'));
db.axis([-1.75 1.75 -1.4 1.23]);

bdf = coco_bd_read('run_fixed');
labs = coco_bd_labs(bdf);
x0 = [];
for lab=labs
  sol = bvp_read_solution('', 'run_fixed', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata', 'line1g3')
  x0 = [x0 ; sol.x(1,:)];
end
db.plot(x0(:,1), x0(:,2), 'numdatal', 'none1');
db.textarrow(x0(end,1), x0(end,2), 1, '1', 'bl', 'lab');
db.xaxis(linspace(-2,2,9),1, 1.65,'y_1');
db.yaxis(linspace(-2,2,9),1, 1.13,'y_2');
db.plot_margin([0.02 0.04 0.02 0.005]);
db.plot_close();

db.plot_create('chap08_fig07b', mfilename('fullpath'));
db.axis([-1.75 1.75 -1.4 1.23]);

bdf = coco_bd_read('run_moving');
labs = coco_bd_labs(bdf);
x0 = [];
for lab=labs
  sol = bvp_read_solution('', 'run_moving', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata', 'line1g3')
  x0 = [x0 ; sol.x(1,:)];
end
db.plot(x0(:,1), x0(:,2), 'numdatal', 'none1');
db.textarrow(x0(end,1), x0(end,2), 1, '1', 'bl', 'lab');
db.xaxis(linspace(-2,2,9),1, 1.65,'y_1');
db.yaxis(linspace(-2,2,9),1, 1.13,'y_2');
db.plot_margin([0.02 0.04 0.02 0.005]);
db.plot_close();

% align plots
plots = {
  'chap08_fig07a' 'chap08_fig07b'
  };

db.plot_align_all_axes(plots);

end
