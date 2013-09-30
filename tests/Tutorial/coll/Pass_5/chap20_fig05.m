function chap20_fig05
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

sol1 = po_read_solution('', 'run1', 3); % eps = 5.6
sol2 = po_read_solution('', 'run1', 7); % eps = 15.3
sol3 = po_read_solution('', 'run1', 10);

db.plot_create('chap20_fig05a', mfilename('fullpath'));
db.paper_size([16 4.85]);
db.axis([-3.0833 3.0833 -1.0794*(1-1/6) 1.0794*(1-1/6)]*1.05);

idx = 1:4:31*4+1;
db.plot(sol3.x(idx,1), sol3.x(idx,2), 'none1', 'marker4s');
db.plot(sol3.x(:,1), sol3.x(:,2), 'numdata');

idx = 1:4:30*4+1;
db.plot(sol2.x(idx,1), sol2.x(idx,2), 'none1', 'marker4s');
db.plot(sol2.x(:,1), sol2.x(:,2), 'numdata');

idx = 1:4:20*4+1;
db.plot(sol1.x(idx,1), sol1.x(idx,2), 'none1', 'marker4s');
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata');

db.textarrow(sol1.x(5,1), sol1.x(5,2), 1, '3:NTST=20', 'bl', 'lab');
db.textarrow(sol2.x(13,1), sol2.x(13,2), 1, '7:NTST=30', 'bl', 'lab');
db.textarrow(sol3.x(73,1), sol3.x(73,2), 1, '10:NTST=31', 'b', 'lab');

db.xaxis(-4:1:4, 2, 2.65, 'y_1');
db.yaxis(-1:0.5:1, 1, 0.75, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();


[~, data] = coll_read_solution('po.seg', 'run1', 1);
coll = data.coll;
TOL1 = coll.TOLINC;
TOL2 = coll.TOLDEC;

bd1 = coco_bd_read('run1');
bd2 = coco_bd_read('run2');

p1 = coco_bd_col(bd1, 'eps');
err1 = coco_bd_col(bd1, 'po.seg.coll.err');
N1 = coco_bd_col(bd1, 'po.seg.coll.NTST');

p2 = coco_bd_col(bd2, 'eps');
err2 = coco_bd_col(bd2, 'po.seg.coll.err');
N2 = coco_bd_col(bd2, 'po.seg.coll.NTST');



db.plot_create('chap20_fig05b', mfilename('fullpath'));
db.paper_size([16 4.5]);

db.plot([0 20], [TOL1 TOL1], 'line2g7');
db.plot([0 20], [TOL2 TOL2], 'line2g7');

db.plot(p1,err1, 'numdata');
db.textarrow(p1(17), err1(17), 3, '\varepsilon:0\rightarrow 20', 't', 'func');

db.plot(p2,err2, 'numdata');
db.textarrow(p2(55), err2(55), 6, '\varepsilon:0\leftarrow 20', 't', 'func');

db.axis([0 20 0 coll.TOL]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:2.0e-4:1.0e-3, 1, 8.8e-4, 'ERR', 'text');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();



db.plot_create('chap20_fig05c', mfilename('fullpath'));
db.paper_size([16 4.5]);

db.plot(p1,N1, 'numdata');
db.textarrow(p1(44), N1(44), 2, '\varepsilon:0\rightarrow 20', 'br', 'func');

db.plot(p2,N2, 'numdata');
db.textarrow(p2(26), N2(26), 2, '\varepsilon:0\leftarrow 20', 'tl', 'func');

db.axis([0 20 0 40]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:10:40, 2, [-1.25 35 0], 'NTST', 'text');
db.plot_margin([0.025 0.02 0 0]);
db.plot_close();

db.plot_align_axes({
  'chap20_fig05a'
  'chap20_fig05b'
  'chap20_fig05c'
  });

end
