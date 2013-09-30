function chap08_fig03
addpath('../../coll/Pass_2')
addpath('..')
try
  x0 = compute_run_data();
  db = plotdb(1);
  % plot_first(db, x0);
  plot_second(db);
  rmpath('..')
  rmpath('../../coll/Pass_2')
  coco_clear_cache('reset');
catch e
  rmpath('..')
  rmpath('../../coll/Pass_2')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function x0 = compute_run_data() %#ok<STOUT>
% run demo
oldpath = path;
if coco_exist('po', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);
end

function plot_first(db, x0)

db.plot_create('chap08_fig03a', mfilename('fullpath'));
db.axis(0.01*[-1.25 1.25 -1.25 1.25]);

db.plot(x0(:,2), x0(:,3), 'line1g5');
sol = po_read_solution('', 'po', 1);
db.plot(sol.x(:,2), sol.x(:,3), 'numdata')
db.textarrow(sol.x(36,2), sol.x(36,3), 1, '1', 'tl', 'lab');
db.xaxis(linspace(-0.01,0.01,3),4, 0.007,'y_2');
db.yaxis(linspace(-0.01,0.01,3),4, 0.012,'y_3');
db.plot_margin([0.02 0.02 0 0.01]);
db.plot_close();

db.plot_create('chap08_fig03b', mfilename('fullpath'));
db.axis([-0.5 0.1 -0.1 0.8]);

labs = 1:6;
for lab=labs
  sol = po_read_solution('', 'po', lab);
  db.plot(sol.x(:,2), sol.x(:,3), 'numdata')
  if any(lab==1:3)
    db.textarrow(sol.x(14,2), sol.x(14,3), 1, sprintf('%d', lab), 'tl', 'lab');
  elseif lab==4
    db.textarrow(sol.x(16,2), sol.x(16,3), 1, sprintf('%d', lab), 'br', 'lab');
  elseif lab==5
    db.textarrow(sol.x(16,2), sol.x(16,3), 1, sprintf('%d', lab), 'tr', 'lab');
  elseif lab==6
    db.textarrow(sol.x(16,2), sol.x(16,3), 1, sprintf('%d', lab), 'l', 'lab');
  end
end
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.72,'\!\!\!y_3');
%db.plot_margin([0.03 0.02 0 0.01]);
db.plot_close();

% align plots
plots = {
  'chap08_fig03a' 'chap08_fig03b'
  };

db.plot_align_all_axes(plots);

end

function plot_second(db)

sol = po_read_solution('', 'po', 6);

db.plot_create('chap08_fig04a', mfilename('fullpath'));
db.axis([-0.5 0.1 -0.1 0.8]);

db.plot(sol.x(:,2), sol.x(:,3), 'numdata')
db.textarrow(sol.x(1,2), sol.x(1,3), 1, '6', 'tl', 'lab');
db.xaxis(linspace(-0.5,0.1,7),2, 0.04,'y_2');
db.yaxis(linspace(0,0.8,5),2, 0.72,'\!\!y_3');
db.plot_margin([0.027 0.015 0 0]);
db.plot_close();

db.plot_create('chap08_fig04b', mfilename('fullpath'));
db.axis([-0.5 20 -0.1 0.8]);

db.plot(sol.t, sol.x(:,3), 'numdata')
db.textarrow(sol.t(10), sol.x(10,3), 1, '6', 'br', 'lab');
db.xaxis(linspace(0,20,5),5, 18,'t');
% db.textbox(2, 0.7, 'y_3', 'tl', 'func');
db.yaxis(linspace(0,0.8,5),2, 0.72,'\!\!y_3');
db.plot_margin([0.027 0.015 0 0]);
db.plot_close();

% align plots
plots = {
  'chap08_fig04a' 'chap08_fig04b'
  };

db.plot_align_all_axes(plots);

end
