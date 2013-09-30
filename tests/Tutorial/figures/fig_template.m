function fig_template
oldpath = path;
addpath('..')
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  path(oldpath)
catch e
  path(oldpath)
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
labs = [1 3 6 9 12];

db.plot_create(, mfilename('fullpath'));
db.axis([0 1 0 1]);

p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
db.plot(p1, p2, 'numdata');
for lab=labs
  p1 = coco_bd_val(bd,lab,'p1');
  p2 = coco_bd_val(bd,lab,'p2');
  db.textarrow(p1, p2, 1, sprintf('%d', lab), 'tr', 'lab');
end
db.xaxis(linspace(0,1,6),2, 0.9, 'p_1');
db.yaxis(linspace(0,1,6),2, 0.9, '\!\!p_2');
%db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_create(, mfilename('fullpath'));
db.axis([0 1 0 1]);

for lab=labs;
  sol = _read_solution('', 'run', lab);
  db.plot(sol.x(:,2), sol.x(:,3), 'numdata');
  db.textarrow(sol.x(1,1), sol.x(1,2), 1, sprintf('%d', lab), 'tr', 'lab');
end

db.xaxis(linspace(0,1,6),2, 0.9,'y_1');
db.textbox(0.1, 0.9, 'y_2', 'tl', 'func');
%db.yaxis(linspace(0,1,6),2, 0.9,'y_2');
%db.plot_margin([0.01 0.02 0 0]);

db.plot_close();

% align plots
plots = {
  '' ''
  };

db.plot_align_all_axes(plots);

end
