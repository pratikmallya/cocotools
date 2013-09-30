function chap20_fig04
oldpath = path;
addpath('../../po/adapt');
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

bd1  = coco_bd_read('run1');
bd2  = coco_bd_read('run2');

db.plot_create('chap20_fig04a', mfilename('fullpath'));
db.paper_size([16 4.85]);
db.axis([-3.0833 3.0833 -1.0794*(1-1/6) 1.0794*(1-1/6)]*1.05);

lab = coco_bd_labs(bd1, 'MXCL');
sol1 = po_read_solution('', 'run1', lab);
lab = coco_bd_labs(bd2, 'EP');
sol2 = po_read_solution('', 'run2', lab(end));

idx = 1:4:20*4+1;
db.plot(sol2.x(idx,1), sol2.x(idx,2), 'none1', 'marker4s');
db.plot(sol2.x(:,1), sol2.x(:,2), 'numdata');

idx = 1:4:10*4+1;
db.plot(sol1.x(idx,1), sol1.x(idx,2), 'none1', 'marker4s');
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata');

db.textarrow(sol1.x(5,1), sol1.x(5,2), 1, 'NTST=10, NCOL=4', 'bl', 'lab');
db.textarrow(sol2.x(13,1), sol2.x(13,2), 1, 'NTST=20, NCOL=4', 'bl', 'lab');

db.xaxis(-4:1:4, 2, 2.65, 'y_1');
db.yaxis(-1:0.5:1, 1, 0.75, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();



db.plot_create('chap20_fig04b', mfilename('fullpath'));
db.paper_size([16 4.5]);

idx = 1:4:20*4+1;
db.plot(sol2.t(idx)/sol2.t(end), sol2.x(idx,2), 'none1', 'marker4s');
db.plot(sol2.t/sol2.t(end), sol2.x(:,2), 'numdata');
db.plot(sol2.t(idx)/sol2.t(end), 0*sol2.x(idx,2)-0.95, 'none1', 'marker4s');

db.axis('+', [0.01 0.1]);

db.textarrow(sol2.t(13)/sol2.t(end), sol2.x(13,2), 2, 'NTST=20, NCOL=4', 'tr', 'lab');

db.xaxis(0:0.2:1, 2, 0.92, '\tau');
db.yaxis(-1:0.4:1, 1, 0.78, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();



db.plot_create('chap20_fig04c', mfilename('fullpath'));
db.paper_size([16 4.5]);

p   = coco_bd_col(bd1, 'eps');
err = coco_bd_col(bd1, 'po.seg.coll.err');
db.plot(p,err, 'numdata');
db.textarrow(p(end-3), err(end-3), 1, 'NTST=10, NCOL=4', 'r', 'lab');

p   = coco_bd_col(bd2, 'eps');
err = coco_bd_col(bd2, 'po.seg.coll.err');
db.plot(p,err, 'numdata');
db.textarrow(p(end-6), err(end-6), 1, 'NTST=20, NCOL=4', 'tl', 'lab');

db.axis([0 20 0 0.001]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:2.0e-4:1.0e-3, 1, 8.8e-4, 'ERR', 'text');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_align_axes({
  'chap20_fig04a'
  'chap20_fig04b'
  'chap20_fig04c'
  });

end
