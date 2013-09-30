function chap18_fig01
oldpath = path;
addpath('../../po');
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
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

db.plot_create('chap18_fig01', mfilename('fullpath'));
db.paper_size([16 6]);
db.axis([-3.0833 3.0833 -1.0794 1.0794]*1.05);

bd  = coco_bd_read('run1');
lab = coco_bd_labs(bd, 'EP');
sol1 = po_read_solution('', 'run1', lab(end));
bd  = coco_bd_read('run2');
lab = coco_bd_labs(bd, 'EP');
sol2 = po_read_solution('', 'run2', lab(end));

db.plot(sol2.x(:,1), sol2.x(:,2), 'numdata', 'line1g4');
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata');

db.textarrow(sol1.x(12,1), sol1.x(12,2), 2, 'NTST=10, NCOL=4', 'bl', 'lab');
db.textarrow(sol2.x(550,1), sol2.x(550,2), 5, 'NTST=150, NCOL=5', 'tr', 'lab');

db.xaxis(-4:1:4, 2, 2.65, 'y_1');
db.yaxis(-1:0.5:1, 1, 0.75, '~~~y_2');
db.plot_margin([-0.015 0.02 0 0]);
db.plot_close();

% db.plot_align_all_axes({'chap18_fig01'});

end
