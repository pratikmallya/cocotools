function chap01_fig04
oldpath = path;
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  path(oldpath)
catch e
  path(oldpath)
  rethrow(e);
end
end

function compute_run_data()
% run demo
oldpath = path;
if ~coco_exist('run1', 'run')
  prob = coco_prob();
  prob = coco_set(prob, 'cont', 'PtMX', 100);
  prob = coco_add_func(prob, 'fun', @catenary, [], 'zero', ...
    'u0', [1; 0; cosh(1)]);
  prob = coco_add_pars(prob, '', 1:3, {'a', 'b', 'Y'});
  coco(prob, 'run1', [], 1, {'Y', 'a', 'b'}, [0 10]);
end
path(oldpath);
end

function plot_data(db)

bd = coco_bd_read('run1');
Y  = coco_bd_col(bd, 'Y');
a  = coco_bd_col(bd, 'a');
b  = coco_bd_col(bd, 'b');

Y0 = coco_bd_val(bd, 1, 'Y');
a0 = coco_bd_val(bd, 1, 'a');
b0 = coco_bd_val(bd, 1, 'b');

db.plot_create('chap01_fig04a', mfilename('fullpath'));
db.axis([0 10 0 8]);
db.plot(Y, a, 'numdatal');
db.plot(Y0, a0, 'line1', 'marker4');
db.xaxis(linspace(0,10,6),2, 9, 'Y');
db.yaxis(linspace(0,7,8),1, 7.5, '\!\!\!a');
%db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

db.plot_create('chap01_fig04b', mfilename('fullpath'));
db.axis([0 10 -0.7 0.7]);
db.plot(Y, b, 'numdatal');
db.plot(Y0, b0, 'line1', 'marker4');
db.xaxis(linspace(0,10,6),2, 9, 'Y');
yticks = linspace(-0.6,0.6,7);
ylabs  = yticks(1:end-1);
db.yaxis(yticks,ylabs, 0.59,'b');
db.plot_margin([0.02 0 0.01 0.01]);

db.plot_close();

% align plots
plots = {
  'chap01_fig04a' 'chap01_fig04b'
  };

db.plot_align_all_axes(plots);

end
