function chap08_fig02
addpath('../../coll/Pass_1')
addpath('..')
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  rmpath('..')
  rmpath('../../coll/Pass_1')
  coco_clear_cache('reset');
catch e
  rmpath('..')
  rmpath('../../coll/Pass_1')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()
% run demo
oldpath = path;
if coco_exist('run', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);
end

function plot_data(db)
bd   = coco_bd_read('run');
labs = coco_bd_labs(bd);

db.plot_create('chap08_fig02a', mfilename('fullpath'));
db.paper_size([8 6]);
db.axis([0 1 -0.1 1.5]);
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  db.plot(sol.t, sol.x(:,1), 'numdata');
  db.textarrow(sol.t(15), sol.x(15,1), 1, sprintf('%d', lab), 'tl', 'lab');
end
% db.textbox(0.1, 1.25, 'y_1', 'tl', 'func');
db.xaxis(linspace(0,1,6),2, 0.9, 't');
% db.yaxis(linspace(0,1.5,4),2, 1.37, '\!z');
db.yaxis(linspace(0,1.5,4),2);
% db.plot_margin([0.02 0.005 0 0]);
db.plot_margin([0.01 0.005 0 0]);
db.plot_close();

db.plot_create('chap08_fig02b', mfilename('fullpath'));
db.paper_size([8 6]);
db.axis([0 1 -5 5]);
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  db.plot(sol.t, sol.x(:,2), 'numdata');
  db.textarrow(sol.t(39), sol.x(39,2), 0.5, sprintf('%d', lab), 'tr', 'lab');
end
% db.textbox(0.3, 4, 'y_2', 'tl', 'func');
db.xaxis(linspace(0,1,6),2, 0.9, 't');
% db.yaxis(linspace(-6,6,7),2, 4.2, '\!\!z''');
db.yaxis(linspace(-6,6,7),2);
% db.plot_margin([0.02 0.005 0 0]);
db.plot_margin([0.00 0.005 0 0]);
db.plot_close();

% align plots
plots = {
  'chap08_fig02a' 'chap08_fig02b'
  };

db.plot_align_all_axes(plots);

end
