function chap19_fig02
oldpath = path;
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
if ~(coco_exist('1', 'run') && coco_exist('2', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

cfname = mfilename('fullpath');
cfname = fullfile(fileparts(cfname), 'cache.mat');
if exist(cfname, 'file')
  load('cache');
else
  [sol1 data] = dft_read_solution('', '1', 3); % eps = 6.2
  sol2 = dft_read_solution('', '1', 6); % eps = 15.7
  sol3 = dft_read_solution('', '1', 8);
  data = data.data;
  save('cache', 'data', 'sol1', 'sol2', 'sol3');
end

db.plot_create('chap19_fig02a', mfilename('fullpath'));
db.paper_size([16 4.85]);
db.axis([-3.0833 3.0833 -1.0794*(1-1/6) 1.0794*(1-1/6)]*1.05);

db.plot(sol3.x(:,1), sol3.x(:,2), 'numdata'); %, 'line1g5');
db.plot(sol2.x(:,1), sol2.x(:,2), 'numdata'); %, 'line1g7');
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata');

db.textarrow(sol1.x(100,1), sol1.x(100,2), 1, '3:NMOD=43', 'bl', 'lab');
db.textarrow(sol2.x(130,1), sol2.x(130,2), 1, '6:NMOD=182', 'bl', 'lab');
db.textarrow(sol3.x(360,1), sol3.x(360,2), 1, '8:NMOD=250', 'b', 'lab');

db.xaxis(-4:1:4, 2, 2.65, 'y_1');
db.yaxis(-1:0.5:1, 1, 0.75, '~y_2');
db.plot_margin([-0.015 0.02 0 0.005]);
db.plot_close();


dft = data.dft;
TOL1 = dft.TOLINC;
TOL2 = dft.TOLDEC;

bd1 = coco_bd_read('1');
bd2 = coco_bd_read('2');

db.plot_create('chap19_fig02b', mfilename('fullpath'));
db.paper_size([16 4.5]);

db.plot([0 20], [TOL1 TOL1], 'line2g7');
db.plot([0 20], [TOL2 TOL2], 'line2g7');

p   = coco_bd_col(bd1, 'eps');
err = coco_bd_col(bd1, 'dft.err');
db.plot(p,err, 'numdata');
db.textarrow(p(17), err(17), 2, '\varepsilon:0\rightarrow 20', 't', 'func');

p   = coco_bd_col(bd2, 'eps');
err = coco_bd_col(bd2, 'dft.err');
db.plot(p,err, 'numdata');
db.textarrow(p(58), err(58), 6, '\varepsilon:0\leftarrow 20', 't', 'func');

db.axis([0 20 0 dft.TOL]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:2.0e-4:1.0e-3, 1, 8.8e-4, 'ERR', 'text');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();



db.plot_create('chap19_fig02c', mfilename('fullpath'));
db.paper_size([16 4.5]);

nm = coco_bd_col(bd1, 'dft.NMOD');
p  = coco_bd_col(bd1, 'eps');
db.plot(p,nm, 'numdata');
db.textarrow(p(36), nm(36), 2, '\varepsilon:0\rightarrow 20', 'br', 'func');

nm = coco_bd_col(bd2, 'dft.NMOD');
p  = coco_bd_col(bd2, 'eps');
db.plot(p,nm, 'numdata');
db.textarrow(p(31), nm(31), 2, '\varepsilon:0\leftarrow 20', 'tl', 'func');

db.axis([0 20 0 300]);

db.xaxis(0:5:20, 5, 18.4, '\varepsilon');
db.yaxis(0:100:300, 2, [-1.5 260 0], 'NMOD', 'text');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();

db.plot_align_axes({
  'chap19_fig02a'
  'chap19_fig02b'
  'chap19_fig02c'
  });

end
