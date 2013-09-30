function chap20_fig16
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  addpath('../../po/adapt');
  plot_first(db);
  plot_second(db);
  plot_third(db);
  plot_fourth(db);
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
if ~(coco_exist('3', 'run') && coco_exist('4', 'run') ...
     && coco_exist('5', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd   = coco_bd_read('3');
labs = coco_bd_labs(bd, 'UZ');
lab  = labs(6);
addpath('../Pass_4');
sol = po_read_solution('', '3', lab);
rmpath('../Pass_4');
N   = (numel(sol.t)-1)/4;
idx = 1:4:N*4+1;

db.plot_create('chap20_fig16a', mfilename('fullpath'));
db.axis([-1 0.8 -3 3]);
db.plot(sol.x(idx,1), sol.x(idx,2), 'none1', 'marker4s')
db.plot(sol.x(:,1), sol.x(:,2), 'numdata')
db.xaxis(-1:0.5:1,2, 0.65,'y_1');
db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_create('chap20_fig16b', mfilename('fullpath'));
db.axis([0 1 -2.5 2]);
tt  = sol.t/sol.t(end);
db.plot(tt, sol.x, 'numdata')
db.plot(tt(idx), 0*sol.x(idx,:)-2.3, 'none1', 'marker4s')
db.textarrow(tt(20), sol.x(20,1), 1.5, 'y_1', 't', 'func');
db.textarrow(tt(20), sol.x(20,2), 1.5, 'y_2', 'br', 'func');
db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-2:1:2,2);
%db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig16a' 'chap20_fig16b'
  });

end

function plot_second(db)

bd   = coco_bd_read('4');
labs = coco_bd_labs(bd, 'UZ');
lab  = labs(6);
addpath('../Pass_5');
sol = po_read_solution('', '4', lab);
rmpath('../Pass_5');
N   = (numel(sol.t)-1)/4;
idx = 1:4:N*4+1;

db.plot_create('chap20_fig17a', mfilename('fullpath'));
db.axis([-1 0.8 -3 3]);
db.plot(sol.x(idx,1), sol.x(idx,2), 'none1', 'marker4s')
db.plot(sol.x(:,1), sol.x(:,2), 'numdata')
db.xaxis(-1:0.5:1,2, 0.65,'y_1');
db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_create('chap20_fig17b', mfilename('fullpath'));
db.axis([0 1 -2.5 2]);
tt  = sol.t/sol.t(end);
db.plot(tt, sol.x, 'numdata')
db.plot(tt(idx), 0*sol.x(idx,:)-2.3, 'none1', 'marker4s')
db.textarrow(tt(20), sol.x(20,1), 1.5, 'y_1', 't', 'func');
db.textarrow(tt(20), sol.x(20,2), 1.5, 'y_2', 'br', 'func');
db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-2:1:2,2);
%db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig17a' 'chap20_fig17b'
  });

end

function plot_third(db)

bd   = coco_bd_read('5');
labs = coco_bd_labs(bd, 'UZ');
lab  = labs(6);
addpath('../Pass_6');
sol = po_read_solution('', '5', lab);
rmpath('../Pass_6');
N   = (numel(sol.t)-1)/4;
idx = 1:4:N*4+1;

db.plot_create('chap20_fig18a', mfilename('fullpath'));
db.axis([-1 0.8 -3 3]);
db.plot(sol.x(idx,1), sol.x(idx,2), 'none1', 'marker4s')
db.plot(sol.x(:,1), sol.x(:,2), 'numdata')
db.xaxis(-1:0.5:1,2, 0.65,'y_1');
db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_create('chap20_fig18b', mfilename('fullpath'));
db.axis([0 1 -2.5 2]);
tt  = sol.t/sol.t(end);
db.plot(tt, sol.x, 'numdata')
db.plot(tt(idx), 0*sol.x(idx,:)-2.3, 'none1', 'marker4s')
db.textarrow(tt(80), sol.x(80,1), 1.5, 'y_1', 't', 'func');
db.textarrow(tt(80), sol.x(80,2), 1.5, 'y_2', 'br', 'func');
db.xaxis(0:0.2:1, 4, 0.92, '\tau');
db.yaxis(-2:1:2,2);
%db.plot_margin([0.03 0.02 0 0]);
db.plot_close();

db.plot_align_all_axes({
  'chap20_fig18a' 'chap20_fig18b'
  });

end

function plot_fourth(db)

db.plot_create('chap20_fig19', mfilename('fullpath'));
db.paper_size([16 6]);
db.axis([0 1 0 20]);
lstyle = {'line1g5' 'line1' 'line4'};
txt = {'co-moving' 'moving fixed' 'moving varying'};
run = {'5' '3' '4'};
for i=1:3
  bd = coco_bd_read(run{i});
  pt = coco_bd_col(bd, 'PT');
  pt = pt/pt(end);
  y = log10(coco_bd_col(bd, 'lsol.cond'));
  db.plot(pt, y, lstyle{i});
  db.plot([0.75 0.8], [20-2*i 20-2*i], lstyle{i});
  db.textbox(0.81, 20-2*i, 1, txt{i}, 'r', 'text2');
end
db.textbox(0.025, 17.5, 1, '\log_{10}(\mathrm{cond}(F_u))', 'r', 'math2');
db.xaxis(0:0.1:1,1, 0.925,'\mathrm{PT}_{\mathrm{rel}}');
db.yaxis(0:5:20,1);
db.plot_margin([-0.01 0.03 0 0]);
db.plot_close();

end
