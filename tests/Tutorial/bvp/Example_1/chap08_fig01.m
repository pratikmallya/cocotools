function chap08_fig01
addpath('../../coll/Pass_1')
addpath('..')
try
  [t0 x0] = compute_run_data();
  db = plotdb(1);
  plot_data(db, t0, x0);
  rmpath('..')
  rmpath('../../coll/Pass_1')
  coco_clear_cache('reset');
catch e
  rmpath('..')
  rmpath('../../coll/Pass_1')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function [t0 x0] = compute_run_data() %#ok<STOUT>

% run demo
oldpath = path;
if coco_exist('run', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
path(oldpath);

end

function plot_data(db, t0, x0)
% sol1 = bvp_read_solution('', 'run1a', 1);

bd   = coco_bd_read('run');
labs = coco_bd_labs(bd);

db.plot_create('chap08_fig01a', mfilename('fullpath'));
% db.paper_size([16 2]);
db.axis([0 1 0 3]);
db.plot(t0, x0(:,1), 'line1g7')
% db.plot(linspace(t0(1),t0(2),150), linspace(x0(1,1),x0(2,1),150), 'none1', 'marker1');
% db.plot(sol1.t, sol1.x(:,1), 'line1g7');
sol = bvp_read_solution('', 'run', 1);
db.plot(sol.t, sol.x(:,1), 'numdata');
db.textarrow(sol.t(33), sol.x(33,1), 1, '1', 'br', 'lab');
% db.axis([0 1 0.8 1.1]);
% db.textbox(0.1, 2.5, 'y_1', 'tl', 'func');
db.xaxis(linspace(0,1,6),2, 0.9, 't');
db.yaxis(linspace(0,3,4),2, 2.75, '\!\!\!y_1');
db.plot_margin([0.04 0 0 0]);
db.plot_close();

db.plot_create('chap08_fig01b', mfilename('fullpath'));
%db.paper_size([16 6]);
db.axis([0 1 0 3]);
for lab=labs
  sol = bvp_read_solution('', 'run', lab);
  db.plot(sol.t, sol.x(:,1), 'numdata')
  if any(lab==[11 9 8 1])
    db.textarrow(sol.t(33), sol.x(33,1), 1, sprintf('%d', lab), ...
      'tl', 'text2', 'box1', 'arrow2');
  elseif lab==10
    db.textarrow(sol.t(33), sol.x(33,1), 1, sprintf('%d', lab), ...
      'br', 'text2', 'box1', 'arrow2');
  elseif lab==2
    db.textarrow(sol.t(29), sol.x(29,1), 1, sprintf('%d', lab), ...
      'tr', 'text2', 'box1', 'arrow2');
  elseif lab==3
    db.textarrow(sol.t(37), sol.x(37,1), 1, sprintf('%d', lab), ...
      'br', 'text2', 'box1', 'arrow2');
  elseif lab==4
    db.textarrow(sol.t(35), sol.x(35,1), 1, sprintf('%d', lab), ...
      'b', 'text2', 'box1', 'arrow2');
  elseif lab==5
    db.textarrow(sol.t(37), sol.x(37,1), 2, sprintf('%d', lab), ...
      'tl', 'text2', 'box1', 'arrow2');
  elseif lab==6
    db.textarrow(sol.t(38), sol.x(38,1), 1, sprintf('%d', lab), ...
      'tl', 'text2', 'box1', 'arrow2');
  end
end
% db.textbox(0.1, 2.5, 'y_1', 'tl', 'func');
db.xaxis(linspace(0,1,6),2, 0.9, 't');
db.yaxis(linspace(0,3,4),2, 2.75, '\!\!\!y_1');
db.plot_margin([0.04 0 0 0]);
db.plot_close();

% align plots
plots = {
  'chap08_fig01a' 'chap08_fig01b'
  };

db.plot_align_all_axes(plots);

end
