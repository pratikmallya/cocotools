function chap16_fig04
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  plot_first(db);
  path(oldpath);
catch e
  path(oldpath);
  rethrow(e);
end
end

function compute_run_data()
% run demo
if ~(coco_exist('regular', 'run') && coco_exist('active', 'run') ...
    && coco_exist('cusp', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

db.plot_create('chap16_fig04a', mfilename('fullpath'));
db.paper_size([5.3 4]);

bd1 = coco_bd_read('regular');

x  = coco_bd_col(bd1, '||U||');
ka = coco_bd_col(bd1, 'ka');
db.plot(ka, x, 'numdata')

idx = coco_bd_idxs(bd1, 'EP');
db.plot(ka(idx),x(idx),'none1','marker4');
idx = coco_bd_idxs(bd1, 'FO');
db.plot(ka(idx),x(idx),'none1','marker4');

db.axis([-0.5 0.5 0.4 1.5]);

x = coco_bd_val(bd1, 1, 'ka');
y = coco_bd_val(bd1, 1, '||U||');
db.textarrow(x,y, '1:EP', 't', 'lab');

x = coco_bd_val(bd1, 5, 'ka');
y = coco_bd_val(bd1, 5, '||U||');
db.textarrow(x,y, '5:EP', 'l', 'lab');

x = coco_bd_val(bd1, 10, 'ka');
y = coco_bd_val(bd1, 10, '||U||');
db.textarrow(x,y, '10:EP', 'r', 'lab');

x = coco_bd_val(bd1, 2, 'ka');
y = coco_bd_val(bd1, 2, '||U||');
db.textarrow(x,y, '2:FP', 'l', 'lab');

x = coco_bd_val(bd1, 7, 'ka');
y = coco_bd_val(bd1, 7, '||U||');
db.textarrow(x,y, '7:FP', 'r', 'lab');

db.xaxis(-0.6:0.2:0.6, 2, 0.28, '\kappa');
db.yaxis(0.4:0.1:1.5,0.4:0.2:1.2, 1.39, '\!\!\!\!\!\!\|U\|');

db.plot_margin([0.1 0.02 0.01 0]);
db.plot_close();



db.plot_create('chap16_fig04b', mfilename('fullpath'));
db.paper_size([5.3 4]);

bd1 = coco_bd_read('active');

x  = coco_bd_col(bd1, '||U||');
ka = coco_bd_col(bd1, 'ka');
db.plot(ka, x, 'numdata')

idx = coco_bd_idxs(bd1, 'EP');
db.plot(ka(idx),x(idx),'none1','marker4');
idx = coco_bd_idxs(bd1, 'FO');
db.plot(ka(idx),x(idx),'none1','marker4');

db.axis([-0.5 0.5 0.5 3]);

x = coco_bd_val(bd1, 1, 'ka');
y = coco_bd_val(bd1, 1, '||U||');
db.textarrow(x,y, '1:EP', 't', 'lab');

x = coco_bd_val(bd1, 5, 'ka');
y = coco_bd_val(bd1, 5, '||U||');
db.textarrow(x,y, '5:EP', 'l', 'lab');

x = coco_bd_val(bd1, 10, 'ka');
y = coco_bd_val(bd1, 10, '||U||');
db.textarrow(x,y, '10:EP', 'r', 'lab');

x = coco_bd_val(bd1, 3, 'ka');
y = coco_bd_val(bd1, 3, '||U||');
db.textarrow(x,y, '3:FP', 'tl', 'lab');

x = coco_bd_val(bd1, 8, 'ka');
y = coco_bd_val(bd1, 8, '||U||');
db.textarrow(x,y, '8:FP', 'tr', 'lab');

db.xaxis(-0.6:0.2:0.6, 2, 0.28, '\kappa');
db.yaxis(0.5:0.25:3,0.5:0.5:2.5, 2.75, '\!\!\!\!\!\!\|U\|');

db.plot_margin([0.1 0.02 0.01 0]);
db.plot_close();



db.plot_create('chap16_fig04c', mfilename('fullpath'));
db.paper_size([5.3 4]);

bd1 = coco_bd_read('cusp');

la = coco_bd_col(bd1, 'la');
ka = coco_bd_col(bd1, 'ka');
db.plot(ka, la, 'numdata')

idx = coco_bd_idxs(bd1, 'EP');
db.plot(ka(idx),la(idx),'none1','marker4');

db.axis([-0.5 0.5 0 1.3]);

x = coco_bd_val(bd1, 1, 'ka');
y = coco_bd_val(bd1, 1, 'la');
db.textarrow(x,y, '1:EP', 'bl', 'lab');

x = coco_bd_val(bd1, 2, 'ka');
y = coco_bd_val(bd1, 2, 'la');
db.textarrow(x,y, '2:EP', 'r', 'lab');

x = coco_bd_val(bd1, 7, 'ka');
y = coco_bd_val(bd1, 7, 'la');
db.textarrow(x,y, '7:EP', 'l', 'lab');

db.xaxis(-0.6:0.2:0.6, 2, 0.28, '\kappa');
db.yaxis(0:0.1:1.4,0:0.2:1, 1.15, '\lambda');

db.plot_margin([0.1 0.02 0.01 0]);
db.plot_close();


db.plot_align_all_axes({'chap16_fig04a' 'chap16_fig04b' 'chap16_fig04c'});

end
