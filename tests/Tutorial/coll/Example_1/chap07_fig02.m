function chap07_fig02
addpath('../Pass_1')
try
  [t0 x0] = compute_run_data();
  db = plotdb(1);
  plot_data(db, t0, x0);
  coco_clear_cache('reset');
  rmpath('../Pass_1')
catch e
  rmpath('../Pass_1')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function [t0 x0] = compute_run_data() %#ok<STOUT>

% run demo
oldpath = path;
if coco_exist('run1', 'run') && coco_exist('run2', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);

end

function plot_data(db, t0, x0)
t = linspace(0,1,1000);
x = cosh(t);

db.plot_create('chap07_fig02a', mfilename('fullpath'));
db.paper_size([8 2.5]);
db.plot(t, x, 'line1g4');
db.plot(t0, x0(:,1), 'numdata');
% db.textarrow(t0(end), x0(end,1), 2.5, '1', 'br', 'text2', 'box1', 'arrow2');
db.textarrow(0.75, cosh(0.75), 4, '\cosh(t)', 'br', 'func');
db.axis([0 1 0 2]);
db.xaxis(linspace(0,1,6),2, 0.9, 't');
% db.textbox(0.1, 1.5, 'y_1', 'tl', 'func');
db.yaxis(linspace(0,2,3),2, 1.5, '\!\!\!y_1');
%db.xlabel([-0.02 -0.1], '\boldmath$t$', 'math1');
%db.ylabel([-0.08 0.22], '\boldmath$y_1$', 0, 'math1');
%db.plot_margin([0.08 0.05 0 0.0]);
db.plot_margin([0.04 0 0 0]);
db.plot_close();

sol = coll_read_solution('', 'run1', 5);

db.plot_create('chap07_fig02b', mfilename('fullpath'));
db.paper_size([8 2.5]);
%db.plot(t, x, 'line1g6');
db.plot(sol.t, sol.x(:,1), 'numdata');
% db.textarrow(0.8, cosh(0.8), 2.5, '5', 'br', 'text2', 'box1', 'arrow2');
db.axis([0 1 0 2]);
db.xaxis(linspace(0,1,6),2, 0.9,'t');
% db.textbox(0.1, 1.5, 'y_1', 'tl', 'func');
db.yaxis(linspace(0,2,3),2, 1.5, '\!\!\!y_1');
%db.xlabel([-0.02 -0.1], '\boldmath$t$', 'math1');
%db.ylabel([-0.08 0.22], '\boldmath$y_1$', 0, 'math1');
%db.plot_margin([0.08 0.05 0 0.0]);
db.plot_margin([0.04 0 0 0]);
db.plot_close();

% align axes
plots = {
  'chap07_fig02a'
  'chap07_fig02b'
  };

db.plot_align_all_axes(plots);

bd = coco_bd_read('run2');
labs = coco_bd_labs(bd);
db.plot_create('chap07_fig02c', mfilename('fullpath'));
db.axis([0 1 0 3]);
for lab=labs
  sol = coll_read_solution('', 'run2', lab);
  db.plot(sol.t, sol.x(:,1), 'numdata')
  if any(lab==[10 8 1 2])
    db.textarrow(sol.t(33), sol.x(33,1), 1, sprintf('%d', lab), 'tl', 'lab');
  elseif lab==9
    db.textarrow(sol.t(33), sol.x(33,1), 1, sprintf('%d', lab), 'br', 'lab');
  elseif lab==3
    db.textarrow(sol.t(30), sol.x(30,1), 1, sprintf('%d', lab), 'tr', 'lab');
  elseif lab==4
    db.textarrow(sol.t(35), sol.x(35,1), 1, sprintf('%d', lab), 'br', 'lab');
  elseif lab==5
    db.textarrow(sol.t(37), sol.x(37,1), 1.25, sprintf('%d', lab), 'tl', 'lab');
  elseif lab==6
    db.textarrow(sol.t(40), sol.x(40,1), 1, sprintf('%d', lab), 'tl', 'lab');
  end
end
% db.textbox(0.1, 2.5, 'y_1', 'tl', 'func');
db.xaxis(linspace(0,1,6),2, 0.9, 't');
db.yaxis(linspace(0,3,4),2, 2.745, '\!\!\!y_1');
db.plot_margin([0.035 0 0 0]);
db.plot_close();
end
