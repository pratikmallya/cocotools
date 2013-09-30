function chap03_fig02
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  coco_clear_cache('reset');
catch e
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()

% run demo
if ~coco_exist('brusselator', 'run')
  run demodiff
end

end

function plot_data(db)

bd   = coco_bd_read('brusselator');
labs = coco_bd_labs(bd);

db.plot_create('chap03_fig02a', mfilename('fullpath'));
db.axis([0 1 0.8 1.05]);
for lab=labs
  [data sol] = coco_read_solution('finitediff', 'brusselator', lab);
  t = (0:numel(data.f_idx)-1)/(numel(data.f_idx)-1);
  db.plot(t, sol.x(data.f_idx), 'numdatal')
  if lab==2
    db.textarrow(t(23), sol.x(data.f_idx(23)), 1, sprintf('%d', lab), 'br', 'lab');
  elseif lab==3
    db.textarrow(t(29), sol.x(data.f_idx(29)), 1, sprintf('%d', lab), 'br', 'lab');
  else
    db.textarrow(t(29), sol.x(data.f_idx(29)), 1, sprintf('%d', lab), 'tl', 'lab');
  end
end
db.xaxis(linspace(0,1,6),2, 0.93, 'x');
% db.yaxis(0.8:0.05:1.05,2, 1.015, '\!\!\!\!\!f(x)');
db.yaxis(0.8:0.05:1.05,2);
% db.plot_margin([0.06 0.01 0 0]);
db.plot_margin([0.01 0.005 0 0]);
db.plot_close();

db.plot_create('chap03_fig02b', mfilename('fullpath'));
db.axis([0 1 -0.5 7.5]);
for lab=labs
  [data sol] = coco_read_solution('finitediff', 'brusselator', lab);
  t = (0:numel(data.g_idx)-1)/(numel(data.g_idx)-1);
  db.plot(t, sol.x(data.g_idx), 'numdatal')
  if lab==2
    db.textarrow(t(5), sol.x(data.g_idx(5)), 1, sprintf('%d', lab), 'tl', 'lab');
  elseif lab==1
    db.textarrow(t(5), sol.x(data.g_idx(5)), 1, sprintf('%d', lab), 'br', 'lab');
  else
    db.textarrow(t(5), sol.x(data.g_idx(5)), 1, sprintf('%d', lab), 'tr', 'lab');
  end
end
db.xaxis(linspace(0,1,6),2, 0.93, 'x');
% db.yaxis(-1:1:8,1, 6.4, '\!\!\!\!\!\!\!\!\!\!g(x)');
db.yaxis(-1:1:8,1);
% db.plot_margin([0.06 0.01 0 0]);
db.plot_margin([0.00 0.005 0 0]);
db.plot_close();

db.plot_align_all_axes({'chap03_fig02a' 'chap03_fig02b'});

end
