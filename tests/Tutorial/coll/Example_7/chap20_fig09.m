function chap20_fig09
oldpath = path;
addpath('../Pass_5', '../../po/adapt');
try
  [bd sol0 sol1] = compute_run_data();
  db = plotdb(1);
  % plot_first(db, bd);
  plot_second(db, sol0, sol1);
  % plot_third(db, sol0, sol1);
  path(oldpath);
  coco_clear_cache('reset');
catch e
  path(oldpath);
  coco_clear_cache('reset');
  rethrow(e);
end
end

function [bd sol0 sol1] = compute_run_data()
% run demo
if ~(coco_exist('run1b', 'run') && coco_exist('run2b', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
bd   = coco_bd_read('run2b');
sol0 = po_read_solution('', 'run1b', 6); % NTST=23, err=1.2506e-05
sol1 = po_read_solution('', 'run2b', 5); % NTST=79, err=1.5747e-05, T=9.6384e+04
                                         % max(data.mesh.ka)/min(data.mesh.ka) = 9.245e+03
[~, data] = coll_read_solution('po.seg', 'run2b', 5);
fprintf('max(data.mesh.ka)/min(data.mesh.ka) = %.3e\n', ...
  max(data.mesh.ka)/min(data.mesh.ka));
end

function plot_first(db, bd)

db.plot_create('chap20_fig09a', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 100 -7 -2]);

pt  = coco_bd_col(bd,'PT');
err = log10(coco_bd_col(bd,'po.seg.coll.err'));
db.plot(pt, err, 'numdata')
db.plot(pt, 0*err+log10(5.0e-5), 'line2g7')
db.plot(pt, 0*err+log10(1.0e-5), 'line2g7')
db.textarrow(pt(3), err(3), 1.5, '\log_{10}(\mathrm{ERR})', 'tr', 'func');

db.xaxis(0:10:100, 2, 94, 'PT', 'text');
db.yaxis(-7:1:-2, 1);
db.plot_margin([0 0.02 0 0]);
db.plot_close();



db.plot_create('chap20_fig09b', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 100 60 180]);

pt = coco_bd_col(bd,'PT');
N  = coco_bd_col(bd,'po.seg.coll.NTST');
db.plot(pt, N, 'numdata')

db.xaxis(0:10:100, 2, 94, 'PT', 'text');
db.yaxis(0:50:200, 2, 165, 'NTST', 'text');
db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig09a'
  'chap20_fig09b'
  });

end

function plot_second(db, sol0, sol1)

idx1 = 1:4:23*4+1;
idx2 = 1:4:79*4+1;

db.plot_create('chap20_fig09c', mfilename('fullpath'));
db.plot(sol0.x(:,1), sol0.x(:,2), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,1), sol0.x(idx1,2), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata')
db.plot(sol1.x(idx2,1), sol1.x(idx2,2), 'numdata', 'none1', 'marker1l')
db.axis([-0.3 0.25 -0.5 0.1]);
db.xaxis(-0.4:0.1:0.3,2, 0.22,'y_1');
db.yaxis(-0.5:0.1:0.1,2, 0.04,'\!y_2');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();


db.plot_create('chap20_fig09d', mfilename('fullpath'));
db.plot(sol0.x(:,2), sol0.x(:,3), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,2), sol0.x(idx1,3), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,2), sol1.x(:,3), 'numdata')
db.plot(sol1.x(idx2,2), sol1.x(idx2,3), 'numdata', 'none1', 'marker1l')
db.axis([-0.5 0.1 -0.1 0.8]);
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.7,'\!y_3');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig09c'
  'chap20_fig09d'
  });

end

function plot_third(db, sol0, sol1)

N   = numel(sol1.t);
N2  = 4*round((N-1)/8)+1;
idx = [N2:N 2:N2];
tt  = [sol1.t(N2:N)-sol1.t(N2) ; sol1.t(N)+sol1.t(2:N2)-sol1.t(N2)];
tt  = tt/tt(end);
idx2 = 1:4:79*4+1;

db.plot_create('chap20_fig09e', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 1 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(90), sol1.x(idx(90),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(90), sol1.x(idx(90),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(90), sol1.x(idx(90),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();



db.plot_create('chap20_fig09f', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0.5 0.511 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(109), sol1.x(idx(109),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(109), sol1.x(idx(109),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(109), sol1.x(idx(109),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0.5:0.001:0.511, 2, 0.5104, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();



db.plot_create('chap20_fig09g', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0.507 0.5086 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(113), sol1.x(idx(113),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(113), sol1.x(idx(113),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(113), sol1.x(idx(113),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0.507:0.0002:0.5086, 2, 0.5085, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig09e'
  'chap20_fig09f'
  'chap20_fig09g'
  });

end
