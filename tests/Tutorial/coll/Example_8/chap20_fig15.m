function chap20_fig15
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  addpath('../Pass_3', '../../po/adapt', '../../spectral');
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
if ~(coco_exist('1', 'run') && coco_exist('2', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd   = coco_bd_read('1');
labs = coco_bd_labs(bd, 'UZ');

db.plot_create('chap20_fig15a', mfilename('fullpath'));
db.axis([-1 0.8 -3 3]);
lab = coco_bd_labs(bd, 'MXCL');
sol = dft_read_solution('', '1', lab);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata', 'line1g6')
for lab=labs
  sol = dft_read_solution('', '1', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata')
end
db.xaxis(-1:0.5:1,2, 0.65,'y_1');
db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
db.plot_margin([0.03 0.02 0 0.005]);
db.plot_close();

bd   = coco_bd_read('2');
labs = coco_bd_labs(bd, 'UZ');

db.plot_create('chap20_fig15b', mfilename('fullpath'));
db.axis([-1 0.8 -3 3]);
lab = coco_bd_labs(bd, 'MXCL');
sol = po_read_solution('', '2', lab);
db.plot(sol.x(:,1), sol.x(:,2), 'numdata', 'line1g6')
for lab=labs
  sol = po_read_solution('', '2', lab);
  db.plot(sol.x(:,1), sol.x(:,2), 'numdata')
end
db.xaxis(-1:0.5:1,2, 0.65,'y_1');
db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
db.plot_margin([0.03 0.02 0 0.005]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig15a' 'chap20_fig15b'
  });

end
