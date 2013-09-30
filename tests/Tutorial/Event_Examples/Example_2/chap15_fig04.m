function chap15_fig04
oldpath = path;
addpath('../../coll/Pass_1')
addpath('../../hspo')
addpath('../../msbvp')
try
  compute_run_data();
  db = plotdb(1);
  % plot_first(db);
  % plot_second(db);
  % plot_third(db);
  plot_fourth(db);
  path(oldpath);
catch e
  path(oldpath);
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

db.plot_create('chap15_fig04', mfilename('fullpath'));
db.paper_size([16 6]);

bd1 = coco_bd_read('run1');
A = coco_bd_col(bd1, 'A');
y = coco_bd_col(bd1, '||U||');
db.plot(A,y,'numdata');
idx = coco_bd_idxs(bd1, 'EP');
db.plot(A(idx),y(idx),'none1','marker4');
idx = coco_bd_idxs(bd1, 'GR');
db.plot(A(idx),y(idx),'none1','marker4');
db.axis([0.05 1.05 21 31]);

A = coco_bd_val(bd1, 1, 'A');
y = coco_bd_val(bd1, 1, '||U||');
db.textarrow(A, y, '1:EP', 't', 'lab');
A = coco_bd_val(bd1, 6, 'A');
y = coco_bd_val(bd1, 6, '||U||');
db.textarrow(A, y, '6:GR', 'r', 'lab');
A = coco_bd_val(bd1, 11, 'A');
y = coco_bd_val(bd1, 11, '||U||');
db.textarrow(A, y, '11:EP', 'b', 'lab');

db.xaxis(0:0.1:1, 2, 0.95, 'A');
db.yaxis(22:2:30,2, 28.7, '\!\!\|U\|');

db.plot_margin([0.02 0.01 0 0]);
db.plot_close();

% db.plot_align_all_axes(plots);

end

function plot_second(db)

suff  = 'a';
plots = {};
labs  = [1 6 11];

for lab = labs
  plot = sprintf('chap15_fig05%c', suff);
  db.plot_create(plot, mfilename('fullpath'));
  db.paper_size([5.3 4]);
  db.axis([-1.5 2 -2 2]);
  
  sol = msbvp_read_solution('', 'run1', lab);
  db.plot(sol{1}.x(:,1),sol{1}.x(:,2), 'numdata');
  db.plot(sol{2}.x(:,1),sol{2}.x(:,2), 'numdata', 'line1g4');
  db.plot([1 1], [-2 2], 'line2');

  if lab==11
    db.textarrow(sol{1}.x(10,1), sol{1}.x(10,2), sprintf('%d', lab), 'tl', 'lab');
  else
    db.textarrow(sol{1}.x(10,1), sol{1}.x(10,2), sprintf('%d', lab), 'bl', 'lab');
  end
  
  db.xaxis(-1:1:2, 2, 1.5, 'y_1');
  db.yaxis(-2:1:2, 2, 1.5, '\!\!y_2');
  db.plot_margin([0.04 0.03 0.01 0]);
  db.plot_close();
  plots = [ plots { plot } ]; %#ok<AGROW>
  suff = char(suff + 1);
end

db.plot_align_all_axes(plots);

end

function plot_third(db)

db.plot_create('chap15_fig06', mfilename('fullpath'));
db.paper_size([16 6]);

bd1 = coco_bd_read('run2');
A = coco_bd_col(bd1, 'A');
y = coco_bd_col(bd1, 'w');
db.plot(A,y,'numdata');
idx = coco_bd_idxs(bd1, 'EP');
db.plot(A(idx),y(idx),'none1','marker4');
db.axis([0 1 0 1.5]);

A = coco_bd_val(bd1, 1, 'A');
y = coco_bd_val(bd1, 1, 'w');
db.textarrow(A, y, '1:EP', 'l', 'lab');
A = coco_bd_val(bd1, 11, 'A');
y = coco_bd_val(bd1, 11, 'w');
db.textarrow(A, y, '11:EP', 'l', 'lab');
A = coco_bd_val(bd1, 16, 'A');
y = coco_bd_val(bd1, 16, 'w');
db.textarrow(A, y, '16:EP', 'bl', 'lab');

db.xaxis(0:0.1:1, 2, 0.95, 'A');
db.yaxis(0:0.5:1.5,2, 1.3, '~~\omega');

db.plot_margin([-0.005 0.01 0 0]);
db.plot_close();

% db.plot_align_all_axes(plots);

end

function plot_fourth(db)

suff  = 'a';
plots = {};
labs  = [16 1 11];

for lab = labs
  plot = sprintf('chap15_fig07%c', suff);
  db.plot_create(plot, mfilename('fullpath'));
  db.paper_size([5.3 4]);
  db.axis([-1.1 1.1 -2 2]);
  
  sol = msbvp_read_solution('', 'run2', lab);
  db.plot(sol{1}.x(:,1),sol{1}.x(:,2), 'numdata');
  db.plot(sol{2}.x(:,1),sol{2}.x(:,2), 'numdata', 'line1g4');
  db.plot([1 1], [-2 2], 'line2');

  if lab==11
    db.textarrow(sol{1}.x(10,1), sol{1}.x(10,2), sprintf('%d', lab), 'tl', 'lab');
  elseif lab==16
    db.textarrow(sol{1}.x(15,1), sol{1}.x(15,2), sprintf('%d', lab), 'bl', 'lab');
  else
    db.textarrow(sol{1}.x(8,1), sol{1}.x(8,2), sprintf('%d', lab), 'bl', 'lab');
  end
  
  db.xaxis(-1.2:0.2:1.1, -0.8:0.4:0.8, 0.95, 'y_1');
  db.yaxis(-2:1:2, 2, 1.5, '\!\!y_2');
  db.plot_margin([0.04 0.03 0.01 0]);
  db.plot_close();
  plots = [ plots { plot } ]; %#ok<AGROW>
  suff = char(suff + 1);
end

db.plot_align_all_axes(plots);

end
