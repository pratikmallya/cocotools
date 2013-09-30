function chap01_fig06
oldpath = path;
addpath('../../../calc_var')
try
  compute_run_data();
  db = plotdb(1);
  plot_data(db);
  path(oldpath)
  coco_clear_cache('reset');
catch e
  path(oldpath)
  coco_clear_cache('reset');
  rethrow(e);
end
end

function compute_run_data()
% run demo
oldpath = path;
if ~coco_exist('run1', 'run')
  seg.t0 = 0:0.01:1;
  seg.x0  = cosh(seg.t0);
  prob = coco_prob();
  prob = coco_set(prob, 'calcvar', 'ParNames', 'Y');
  prob = calcvar_start(prob, '', @catenary, seg, cosh(1));
  prob = coco_add_event(prob, 'UZ', 'Y', [2 3 4]);
  coco(prob, 'run1', [], 1, 'Y', [0 5]);
end
path(oldpath);
end

function plot_data(db)

bd   = coco_bd_read('run1');
labs = coco_bd_labs(bd, 'UZ');

db.plot_create('chap01_fig06', mfilename('fullpath'));
db.axis([-0.02 1.02 -0.08 4.08]);

lines = {'line1' 'line1g5' 'line1' 'line1' 'line1g5' 'line1'};
idx = 1;
for lab=labs;
  [t x] = calcvar_read_sol('', 'run1', lab);
  db.plot(t, x, 'numdatal', lines{idx});
  %db.textarrow(sol.x(1,1), sol.x(1,2), 1, sprintf('%d', lab), 'tr', 'lab');
  idx = idx+1;
end
db.xaxis(linspace(0,1,6),2, 0.9, 'x');
db.textbox(0.85, 3.6, 'f', 'tr', 'func');
db.yaxis(linspace(0,4,5),2);
%db.plot_margin([0.01 0.02 0 0]);
db.plot_close();

% align plots
plots = {
  'chap01_fig05' 'chap01_fig06'
  };

db.plot_align_all_axes(plots);

end
