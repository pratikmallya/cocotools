function chap17_fig02
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
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
if ~(coco_exist('run', 'run'))
  oldpath = path;
  run demo
  path(oldpath);
end
end

function plot_first(db)

bd = coco_bd_read('run', 'bd');

p1 = coco_bd_col(bd, 'p1');
p2 = coco_bd_col(bd, 'p2');
idx1 = coco_bd_idxs(bd, 'HB');
idx2 = coco_bd_idxs(bd, 'FO');
idx3 = coco_bd_idxs(bd, 'NSad');

db.plot_create('chap17_fig02a', mfilename('fullpath'));

x = linspace(0,0.25,100);
y = (1+sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')
y = (1-sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')

db.plot(p1(idx1),p2(idx1),'none1', 'marker2l')
db.plot(p1(idx2),p2(idx2),'none1', 'marker4l')

db.axis([0 0.5 0 0.255]);

db.xaxis(0:0.1:0.5, 1, 0.44, 'p_1');
db.yaxis(0:0.1:0.3,2, 0.235, '\!p_2');

db.plot_margin([0.02 0.03 0 0.005]);
db.plot_close();




db.plot_create('chap17_fig02b', mfilename('fullpath'));

x = linspace(0,0.25,100);
y = (1+sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')
y = (1-sqrt(1-4*x)+2*x)./(4+2*x);
db.plot(y,x,'line1g4')

db.plot(p1(idx1),p2(idx1),'none1', 'marker2l')
db.plot(p1(idx3),p2(idx3),'none2', 'marker6l')
db.plot(p1(idx2),p2(idx2),'none1', 'marker4l')

db.axis([0 0.5 0 0.255]);

db.xaxis(0:0.1:0.5, 1, 0.44, 'p_1');
db.yaxis(0:0.1:0.3,2, 0.235, '\!p_2');

db.plot_margin([0.02 0.03 0 0.005]);
db.plot_close();

db.plot_align_all_axes({'chap17_fig02a' 'chap17_fig02b'});

end
