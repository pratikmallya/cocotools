function chap09_fig04
oldpath = path;
addpath('..');
addpath('../../coll/Pass_2');
addpath('../../msbvp')
try
  compute_run_data();
  db = plotdb(1);
  % plot_first(db);
  plot_second(db);
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

suff  = 'a';
plots = {};
labs  = [4 1 2];

for lab = labs
  plot = sprintf('chap09_fig04%c', suff);
  db.plot_create(plot, mfilename('fullpath'));
  db.paper_size([5.3 4]);
  db.axis([0 0.8 -0.3 0.3]);
  
  db.plot([0.5 0.5], [-0.3 0.3], 'line2');
  
  sol = msbvp_read_solution('', 'run1', lab);
  db.plot(sol{1}.x(:,1), sol{1}.x(:,2), 'numdata', 'line1g5')
  db.plot(sol{2}.x(:,1), sol{2}.x(:,2), 'numdata')

  db.textarrow(sol{2}.x(23,1), sol{2}.x(23,2), sprintf('%d', lab), 'b', 'lab');
  
  db.xaxis(linspace(0,0.8,5), 2, 0.68, 'z_1');
  db.yaxis(linspace(-0.3,0.3,7),linspace(-0.2,0.2,3), 0.25, '\dot{z}_1');
  db.plot_margin([0.03 0.02 0.005 0.005]);
  db.plot_close();
  plots = [ plots { plot } ]; %#ok<AGROW>
  suff = char(suff + 1);
end

db.plot_align_all_axes(plots);

end

function plot_second(db)

suff  = 'a';
plots = {};
labs  = [4 1 2];

for lab = labs
  plot = sprintf('chap09_fig05%c', suff);
  db.plot_create(plot, mfilename('fullpath'));
  db.paper_size([5.3 4]);
  db.axis([0 0.8 -0.4 0.4]);
  
  db.plot([0.5 0.5], [-0.4 0.4], 'line2');
  
  sol = msbvp_read_solution('', 'run2', lab);
  db.plot(sol{1}.x(:,1), sol{1}.x(:,2), 'numdata', 'line1g5')
  db.plot(sol{2}.x(:,1), sol{2}.x(:,2), 'numdata')
  db.plot(sol{3}.x(:,2), sol{3}.x(:,3), 'numdata')

  db.textarrow(sol{2}.x(10,1), sol{2}.x(10,2), sprintf('%d', lab), 'br', 'lab');
  
  db.xaxis(linspace(0,0.8,5), 2, 0.68, 'z_1');
  db.yaxis(linspace(-0.4,0.4,9),linspace(-0.4,0.4,5), 0.28, '\dot{z}_1');
  db.plot_margin([0.03 0.02 0 0]);
  db.plot_close();
  plots = [ plots { plot } ]; %#ok<AGROW>
  suff = char(suff + 1);
end

db.plot_align_all_axes(plots);

end
