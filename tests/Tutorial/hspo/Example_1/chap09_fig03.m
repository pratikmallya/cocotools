function chap09_fig03
addpath('../../coll/Pass_1')
addpath('../../msbvp')
addpath('..')
try
  [x1 x2 rlab] = compute_run_data();
  db = plotdb(1);
  plot_data(db, x1,x2,rlab);
  rmpath('..')
  rmpath('../../msbvp')
  rmpath('../../coll/Pass_1')
  coco_clear_cache('reset');
catch e
  rmpath('..')
  rmpath('../../msbvp')
  coco_clear_cache('reset');
  rethrow(e);
end
end

function [x1 x2 rlab] = compute_run_data() %#ok<STOUT>
% run demo
oldpath = path;
if coco_exist('run1', 'run') && coco_exist('run2', 'run')
  coco = @(prob, run, varargin) coco_bd_read(run); %#ok<NASGU>
end
run demo
rlab = 9;
path(oldpath);
end

function plot_data(db, x1, x2, rlab)

alim = [-1.5 4 -3 5];

db.plot_create('chap09_fig03a', mfilename('fullpath'));
db.paper_size([8 6]);
db.axis(alim);

db.plot([0 0], alim(3:4), 'line2g5');

bd   = coco_bd_read('run1');
labs = coco_bd_labs(bd);
idx = 52;
for lab=labs
  [sol data] = msbvp_read_solution('', 'run1', lab);
  for i=1:data.nsegs
    if lab == rlab
      db.plot(sol{i}.x(:,1), sol{i}.x(:,2), 'numdata', 'line1g5')
    elseif lab==6
    else
      db.plot(sol{i}.x(:,1), sol{i}.x(:,2), 'numdata')
    end
  end
  if any(lab==[1:2 7:11])
    db.textarrow(sol{2}.x(idx,1), sol{2}.x(idx,2), 0.5, sprintf('%d', lab), 'b', 'lab');
    idx = idx+0;
  elseif lab==5
    db.textarrow(sol{2}.x(40,1), sol{2}.x(40,2), 0.5, sprintf('%d', lab), 'l', 'lab');
  elseif lab==4
    db.textarrow(sol{2}.x(40,1), sol{2}.x(40,2), 0.5, sprintf('%d', lab), 'tr', 'lab');
  elseif lab==3
    db.textarrow(sol{2}.x(35,1), sol{2}.x(35,2), 0.5, sprintf('%d', lab), 'r', 'lab');
  end
end
db.plot(x1(:,1), x1(:,2), 'line1g1');
db.plot(x2(:,1), x2(:,2), 'line1g1');
db.plot(x1(:,1), x1(:,2), 'line4');
db.plot(x2(:,1), x2(:,2), 'line4');

db.xaxis(linspace(-1,4,6),2, 3.6, 'y_1');
db.yaxis(linspace(-2,4,4),2, 4.7, '\!\!y_2');
db.plot_margin([0.025 0.02 0 0.01]);
db.plot_close();

db.plot_create('chap09_fig03b', mfilename('fullpath'));
db.paper_size([8 6]);
db.axis(alim);

db.plot([0 0], alim(3:4), 'line3g7');

bd   = coco_bd_read('run2');
labs = coco_bd_labs(bd);
idx = 60;
for lab=labs
  [sol data] = msbvp_read_solution('', 'run2', lab);
  for i=1:data.nsegs
    if abs(sol{i}.p(1)-1)<10*eps
      db.plot(sol{i}.x(:,1), sol{i}.x(:,2), 'numdata', 'line1g5')
    else
      db.plot(sol{i}.x(:,1), sol{i}.x(:,2), 'numdata')
    end
  end
  if any(lab==[2:4 6])
    db.textarrow(sol{2}.x(idx,1), sol{2}.x(idx,2), 0.5, sprintf('%d', lab), ...
      'bl', 'lab');
    idx = idx-2;
  elseif lab==1
    db.textarrow(sol{2}.x(40,1), sol{2}.x(40,2), 0.5, sprintf('%d', lab), ...
      'l', 'lab');
    idx = 30;
  elseif lab==5
    db.textarrow(sol{2}.x(idx,1), sol{2}.x(idx,2), 0.5, sprintf('%d', lab), ...
      'tr', 'lab');
    idx = idx-2;
  elseif any(lab==8:10)
    db.textarrow(sol{2}.x(idx,1), sol{2}.x(idx,2), 0.5, sprintf('%d', lab), ...
      'tl', 'lab');
    idx = idx-8;
  elseif lab==11
    db.textarrow(sol{2}.x(20,1), sol{2}.x(20,2), 0.5, sprintf('%d', lab), ...
      'br', 'lab');
  end
end
db.xaxis(linspace(-1,4,6),2, 3.6,'y_1');
db.yaxis(linspace(-2,4,4),2, 4.7, '\!\!y_2');
db.plot_margin([0.025 0.02 0 0.01]);
db.plot_close();

end
