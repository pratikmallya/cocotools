function chap20_fig14
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  addpath('../Pass_5', '../../po/adapt');
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
if ~(coco_exist('4', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

suff = char('b'+(0:7));
bd   = coco_bd_read('4');
labs = coco_bd_labs(bd, 'UZ');

db.plot_create('chap20_fig14a', mfilename('fullpath'));
db.paper_size([5.3 4]);
db.axis([-1.01 -0.9 85 700]);
a = coco_bd_col(bd, 'a');
y = coco_bd_col(bd, '||U||');
db.plot(a, y, 'line1');
i = 1;
for lab=labs
  a = coco_bd_val(bd, lab, 'a');
  y = coco_bd_val(bd, lab, '||U||');
  txt = sprintf('%d', i);
  if i<=5
    db.textarrow(a, y, 1, txt, 'l', 'lab');
  elseif i<=7
    db.textarrow(a, y, 1, txt, 'r', 'lab');
  else
    db.textarrow(a, y, 1, txt, 'b', 'lab');
  end
  i = i+1;
end
db.xaxis(-1.05:0.05:0.9,5, -0.92,'a');
db.yaxis(100:200:700,2, 585,'\!\!\!\!\|U\|');
db.plot_margin([0.06 0.01 0 0]);
db.plot_close();

for i=1:8
  sol = po_read_solution('', '4', labs(i));
  plot = sprintf('chap20_fig14%c', suff(i));
  db.plot_create(plot, mfilename('fullpath'));
  db.paper_size([5.3 4]);
  db.axis([-1 0.8 -3 3]);
  db.plot(sol.x(:,1), sol.x(:,2), 'line1')
  txt = sprintf('%d', i);
  db.textarrow(sol.x(1,1), sol.x(1,2), 1, txt, 'br', 'lab');
  db.xaxis(-1:0.5:1,2, 0.65,'y_1');
  db.yaxis(-4:2:4,2, 2.5,'\!\!y_2');
  db.plot_margin([0.02 0.03 0 0]);
  db.plot_close();
end

db.plot_align_all_axes({
  'chap20_fig14a' 'chap20_fig14b' 'chap20_fig14c'
  'chap20_fig14d' 'chap20_fig14e' 'chap20_fig14f'
  'chap20_fig14g' 'chap20_fig14h' 'chap20_fig14i'
  });

end
