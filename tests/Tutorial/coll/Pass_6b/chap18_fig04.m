function chap18_fig04
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
if ~(coco_exist('run1', 'run') && coco_exist('run2', 'run') ...
    && coco_exist('run3', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd1  = coco_bd_read('run1');
bd2  = coco_bd_read('run2');
bd3  = coco_bd_read('run3');

db.plot_create('chap18_fig04a', mfilename('fullpath'));
db.paper_size([16 4.85]);
db.axis([-3.0833 3.0833 -1.0794*(1-1/6) 1.0794*(1-1/6)]*1.05);

lab  = coco_bd_labs(bd1, 'MXCL');
sol1 = po_read_solution('', 'run1', lab);
lab  = coco_bd_labs(bd2, 'MXCL');
sol2 = po_read_solution('', 'run2', lab);
lab  = coco_bd_labs(bd3, 'EP');
sol3 = po_read_solution('', 'run3', lab(end));

idx = 1:5:50*5+1;
db.plot(sol3.x(idx,1), sol3.x(idx,2), 'none1', 'marker4s');
db.plot(sol3.x(:,1), sol3.x(:,2), 'numdata');

% idx = 1:4:20*4+1;
% db.plot(sol2.x(idx,1), sol2.x(idx,2), 'none1', 'marker4');
% db.plot(sol2.x(:,1), sol2.x(:,2), 'numdata');
% 
% idx = 1:4:10*4+1;
% db.plot(sol1.x(idx,1), sol1.x(idx,2), 'none1', 'marker4');
% db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata');

% db.textarrow(sol1.x(9,1), sol1.x(9,2), 1, 'NTST=10, NCOL=4', 'bl', 'lab');
% db.textarrow(sol2.x(25,1), sol2.x(25,2), 1, 'NTST=20, NCOL=4', 'r', 'lab');
% db.textarrow(sol3.x(171,1), sol3.x(171,2), 1, 'NTST=50, NCOL=5', 'tr', 'lab');

db.xaxis(-4:1:4, 2, 2.65, 'y_1');
db.yaxis(-1:0.5:1, 1, 0.75, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();



db.plot_create('chap18_fig04b', mfilename('fullpath'));
db.paper_size([16 4.5]);

idx = 1:5:50*5+1;
db.plot(sol3.t(idx)/sol3.t(end), sol3.x(idx,2), 'none1', 'marker4s');
db.plot(sol3.t/sol3.t(end), sol3.x(:,2), 'numdata');
db.plot(sol3.t(idx)/sol3.t(end), 0*sol3.x(idx,2)-0.95, 'none1', 'marker4s');

% idx = 1:4:20*4+1;
% db.plot(sol2.t(idx)/sol2.t(end), sol2.x(idx,2), 'none1', 'marker4');
% db.plot(sol2.t/sol2.t(end), sol2.x(:,2), 'numdata');
% 
% idx = 1:4:10*4+1;
% db.plot(sol1.t(idx)/sol1.t(end), sol1.x(idx,2), 'none1', 'marker4');
% db.plot(sol1.t/sol1.t(end), sol1.x(:,2), 'numdata');

db.axis('+', [0.01 0.1]);

% db.textarrow(sol1.t(11)/sol1.t(end), sol1.x(11,2), 2, 'NTST=10, NCOL=4', 'bl', 'lab');
% db.textarrow(sol2.t(59)/sol2.t(end), sol2.x(59,2), 2, 'NTST=20, NCOL=4', 'tl', 'lab');
% db.textarrow(sol3.t(200)/sol3.t(end), sol3.x(200,2), 2, 'NTST=50, NCOL=5', 'tr', 'lab');

db.xaxis(0:0.2:1, 2, 0.92, '\tau');
db.yaxis(-1:0.4:1, 1, 0.78, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();



db.plot_create('chap18_fig04c', mfilename('fullpath'));
db.paper_size([16 4.5]);

p   = coco_bd_col(bd1, 'eps');
err = coco_bd_col(bd1, 'po.seg.coll.err');
db.plot(p,err, 'numdata');
db.textarrow(p(end), err(end), 1, 'NTST=10, NCOL=4', 'r', 'lab');

p   = coco_bd_col(bd2, 'eps');
err = coco_bd_col(bd2, 'po.seg.coll.err');
db.plot(p,err, 'numdata');
db.textarrow(p(end-3), err(end-3), 1, 'NTST=20, NCOL=4', 'r', 'lab');

p   = coco_bd_col(bd3, 'eps');
err = coco_bd_col(bd3, 'po.seg.coll.err');
db.plot(p,err, 'numdata');
db.textarrow(p(end-26), err(end-26), 1, 'NTST=50, NCOL=5', 'tl', 'lab');

db.axis([0 20 0 0.001]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:2.0e-4:1.0e-3, 1, 8.8e-4, 'ERR', 'text');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_align_axes({
  'chap18_fig04a'
  'chap18_fig04b'
  'chap18_fig04c'});

end
