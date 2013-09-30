function chap03_fig01
try
  bd = compute_run_data();
  db = plotdb(1);
  plot_data(db, bd);
  coco_clear_cache('reset');
catch e
  coco_clear_cache('reset');
  rethrow(e);
end
end

function bd = compute_run_data()

% run demo
if coco_exist({'frank' 'run6'}, 'run')
  bd = coco_bd_read({'frank' 'run6'});
else
  u0 = [1; 0.3; 1.275; -0.031; -0.656; 0.382; 0.952; ...
    -0.197; -0.103; 0.286; 1.275; -0.031];
  prob = period(u0, 4);
  prob = coco_add_pars(prob, 'pars', [1 2], {'a' 'b'});
  prob = coco_add_pars(prob, 'xy', 3:10, ...
    {'x1' 'y1' 'x2' 'y2' 'x3' 'y3' 'x4' 'y4'}, 'active');
  prob = coco_set(prob, 'cont', 'FP', true);
  bd = coco(prob, {'frank' 'run6'}, [], 1, 'a', [0.8 1.2]);
end

end

function plot_data(db, bd)

db.plot_create('chap03_fig01a', mfilename('fullpath'));
a = coco_bd_col(bd, 'a');
x = coco_bd_col(bd, 'x1');
db.plot(a,x, 'numdatal');
lab = coco_bd_labs(bd, 'FP');
a   = coco_bd_val(bd, lab, 'a');
x   = coco_bd_val(bd, lab, 'x1');
db.plot(a,x, 'numdata', 'none1', 'marker4l');
db.axis([0.9 1.21 0.7 1.3]);
db.xaxis(0.9:0.1:1.3,5, 1.175, 'a');
db.yaxis(0.7:0.1:1.3,2, 1.25, '\!\!x_1');
db.plot_margin([0.02 0 0 0]);
db.plot_close();


db.plot_create('chap03_fig01b', mfilename('fullpath'));

x1 = coco_bd_col(bd, 'x1');
x2 = coco_bd_col(bd, 'x2');
x3 = coco_bd_col(bd, 'x3');
x4 = coco_bd_col(bd, 'x4');
y1 = coco_bd_col(bd, 'y1');
y2 = coco_bd_col(bd, 'y2');
y3 = coco_bd_col(bd, 'y3');
y4 = coco_bd_col(bd, 'y4');

db.plot(x1,y1, 'none1', 'marker1l');
db.plot(x2,y2, 'none1', 'marker1l');

db.textarrow(x1(1)-0.01, y1(1)+0.01, 1.5, '(x_1,y_1)', 'tl', 'func');
db.textarrow(x2(1)+0.01, y2(1)+0.01, 1.5, '(x_2,y_2)', 'tr', 'func');
db.textarrow(x3(1)-0.03, y3(1)+0.01, 1.5, '(x_3,y_3)', 'tl', 'func');
db.textarrow(x4(1)+0.01, y4(1)-0.01, 1.5, '(x_4,y_4)', 'br', 'func');

lab = coco_bd_labs(bd, 'FP');
x1  = coco_bd_val(bd, lab, 'x1');
y1  = coco_bd_val(bd, lab, 'y1');
db.plot(x1,y1, 'numdata', 'none1', 'marker4l');
x2  = coco_bd_val(bd, lab, 'x2');
y2  = coco_bd_val(bd, lab, 'y2');
db.plot(x2,y2, 'numdata', 'none1', 'marker4l');

db.axis([-0.75 1.3 -0.25 0.4]);
db.xaxis(-1:0.5:1.5,2, 1.07, 'x');
db.yaxis(-0.3:0.1:0.4,1, 0.345, '\!y');
db.plot_margin([0.02 0 0 0]);
db.plot_close();

db.plot_align_all_axes({'chap03_fig01a' 'chap03_fig01b'});

end
