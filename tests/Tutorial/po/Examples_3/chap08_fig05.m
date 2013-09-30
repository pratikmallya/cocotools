function chap08_fig05
addpath('../../coll/Pass_2')
addpath('..')
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  % plot_second(db);
  rmpath('..')
  rmpath('../../coll/Pass_2')
  coco_clear_cache('reset');
catch e
  rmpath('..')
  rmpath('../../coll/Pass_2')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()
% run demo
oldpath = path;
if coco_exist('run1', 'run') && coco_exist('run2', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);
end

function plot_first(db)

sol0 = po_read_solution('', 'run1', 6);
sol1 = po_read_solution('', 'run2', 1);

db.plot_create('chap08_fig05a', mfilename('fullpath'));
db.axis([-10 500 -0.1 0.8]);

db.plot(sol1.t, sol1.x(:,3), 'numdata')
db.textarrow(sol1.t(10), sol1.x(10,3), 1, '1', 'br', 'lab');
db.xaxis(linspace(0,500,6),5, 460,'t');
% db.textbox(80, 0.72, 'y_3', 'tl', 'func');
db.yaxis(linspace(0,0.8,5),2, 0.72,'\!\!y_3');
db.plot_margin([0.027 0.015 0 0]);
db.plot_close();

db.plot_create('chap08_fig05b', mfilename('fullpath'));
db.axis([-0.5 0.1 -0.1 0.8]);

db.plot(sol0.x(:,2), sol0.x(:,3), 'numdata', 'line1g6', 'marker5')
db.plot(sol1.x(:,2), sol1.x(:,3), 'numdatal')
db.textarrow(sol0.x(1,2), sol0.x(1,3), 1, '6', 'tl', 'lab');
db.textarrow(sol1.x(1,2), sol1.x(1,3), 1, '1', 'tr', 'lab');
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.72,'\!\!y_3');
db.plot_margin([0.027 0.015 0 0]);
db.plot_close();

% align plots
plots = {
  'chap08_fig05a' 'chap08_fig05b'
  };

db.plot_align_all_axes(plots);

end

function plot_second(db)

bd   = coco_bd_read('run2');
labs = [1 3 6 9 12];

db.plot_create('chap08_fig06a', mfilename('fullpath'));
db.axis([-0.08 0.0 1 21]);

p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
db.plot(p1, p2, 'numdata');
for lab=labs
  p1 = coco_bd_val(bd,lab,'p1');
  p2 = coco_bd_val(bd,lab,'p2');
  if lab==6
    db.textarrow(p1, p2, 1, sprintf('%d', lab), 'tr', 'lab');
  elseif lab==12
    db.textarrow(p1, p2, 1, sprintf('%d', lab), 'bl', 'lab');
  else
    db.textarrow(p1, p2, 1, sprintf('%d', lab), 'tl', 'lab');
  end
end
db.xaxis(linspace(-0.07,-0.01,4),2, -0.023, 'p_1');
db.yaxis(linspace(0,20,5),2, 17.5,'\!\!p_2');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_create('chap08_fig06b', mfilename('fullpath'));
db.axis([-0.7 0.4 -0.3 1.3]);

% sol0 = po_read_solution('', 'run1', 6);
% db.plot(sol0.x(:,2), sol0.x(:,3), 'line1');

for lab=labs;
  sol = po_read_solution('', 'run2', lab);
  % if lab==1
  %   db.plot(sol.x(:,2), sol.x(:,3), 'numdata', 'line3g3');
  % else
    db.plot(sol.x(:,2), sol.x(:,3), 'numdata');
  % end
  db.textarrow(sol.x(100,2), sol.x(100,3), 1.5, sprintf('%d', lab), 'b', 'lab');
end

db.xaxis(linspace(-0.6,0.4,6),2, 0.3,'y_2');
ytics = linspace(-0.2,1.2,8);
ylabs = ytics;
ylabs(7) = [];
db.yaxis(ytics,ylabs, 1,'y_3');
db.plot_margin([0.02 0 0.005 0]);

db.plot_close();

% align plots
plots = {
  'chap08_fig06a' 'chap08_fig06b'
  };

db.plot_align_all_axes(plots);

end
