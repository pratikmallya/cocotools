function chap20_fig08
oldpath = path;
addpath('../Pass_4', '../../po/adapt');
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
if ~(coco_exist('run1a', 'run') && coco_exist('run2a', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
[~, data] = coll_read_solution('po.seg', 'run2a', 2);
fprintf('max(data.mesh.ka)/min(data.mesh.ka) = %.3e\n', ...
  max(data.mesh.ka)/min(data.mesh.ka));
end

function plot_first(db)

bd = coco_bd_read('run2a');

sol0 = po_read_solution('', 'run1a', 6); % NTST=20, err=2.2619e-05
sol1 = po_read_solution('', 'run2a', 2); % NTST=120, err=4.2620e-05, T=9.6497e+04
                                         % max(data.mesh.ka)/min(data.mesh.ka) = 4.694e+03
                                         
idx1 = 1:4:20*4+1;
idx2 = 1:4:120*4+1;

db.plot_create('chap20_fig08a', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 100 -5 -1]);

pt  = coco_bd_col(bd,'PT');
err = log10(coco_bd_col(bd,'po.seg.coll.err'));
db.plot(pt, err, 'numdata')
db.plot(pt, 0*err-4, 'line2g7')
db.textarrow(pt(7), err(7), 1.5, '\log_{10}(\mathrm{ERR})', 'tr', 'func');

db.xaxis(0:10:100, 2, 94, 'PT', 'text');
db.yaxis(-5:1:-1, 2);
db.plot_margin([-0.005 0.02 -0.01 0]);
db.plot_close();



db.plot_create('chap20_fig08b', mfilename('fullpath'));
db.plot(sol0.x(:,1), sol0.x(:,2), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,1), sol0.x(idx1,2), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,1), sol1.x(:,2), 'numdata')
db.plot(sol1.x(idx2,1), sol1.x(idx2,2), 'numdata', 'none1', 'marker1l')
db.axis([-0.3 0.25 -0.5 0.1]);
db.xaxis(-0.4:0.1:0.3,2, 0.22,'y_1');
db.yaxis(-0.5:0.1:0.1,2, 0.04,'\!y_2');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();


db.plot_create('chap20_fig08c', mfilename('fullpath'));
db.plot(sol0.x(:,2), sol0.x(:,3), 'numdata', 'line1g6')
db.plot(sol0.x(idx1,2), sol0.x(idx1,3), 'numdata', 'none1g6', 'marker5')
db.plot(sol1.x(:,2), sol1.x(:,3), 'numdata')
db.plot(sol1.x(idx2,2), sol1.x(idx2,3), 'numdata', 'none1', 'marker1l')
db.axis([-0.5 0.1 -0.1 0.8]);
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.7,'\!y_3');
db.plot_margin([0.02 0.02 0 0]);
db.plot_close();


N   = numel(sol1.t);
N2  = 4*round((N-1)/8)+1;
idx = [N2:N 2:N2];
tt  = [sol1.t(N2:N)-sol1.t(N2) ; sol1.t(N)+sol1.t(2:N2)-sol1.t(N2)];
tt  = tt/tt(end);
idx2 = 1:4:120*4+1;

db.plot_create('chap20_fig08d', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0 1 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(150), sol1.x(idx(150),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(150), sol1.x(idx(150),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(150), sol1.x(idx(150),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();



db.plot_create('chap20_fig08e', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0.474 0.485 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(196), sol1.x(idx(196),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(196), sol1.x(idx(196),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(196), sol1.x(idx(196),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0.474:0.001:0.485, 2, 0.4845, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();



db.plot_create('chap20_fig08f', mfilename('fullpath'));
db.paper_size([16 4.5]);
db.axis([0.4801 0.4817 -0.7 0.8]);

db.plot(tt, sol1.x(idx,:), 'numdata')
db.plot(tt(idx2), 0*sol1.x(idx2,1)-0.6, 'none1', 'marker4s');
db.textarrow(tt(204), sol1.x(idx(204),1), 1.5, 'y_1', 'tl', 'func');
db.textarrow(tt(204), sol1.x(idx(204),2), 1.5, 'y_2', 'bl', 'func');
db.textarrow(tt(204), sol1.x(idx(204),3), 1.5, 'y_3', 'bl', 'func');

db.xaxis(0.4801:0.0002:0.4817, 2, 0.4816, '\tau');
db.yaxis(-1:0.5:1, 2);
db.plot_margin([-0.01 0.02 -0.01 0.01]);
db.plot_close();

db.plot_align_all_axes({'chap20_fig08b' 'chap20_fig08c'});

db.plot_align_all_axes({
  'chap20_fig08d'
  'chap20_fig08e'
  'chap20_fig08f'
  });

end
