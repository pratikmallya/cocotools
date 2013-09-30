function chap01_fig05
oldpath = path;
addpath('../../../coll/Pass_1')
addpath('../../../bvp')
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
  t0 = (0:0.01:1)';
  x0 = [cosh(t0) sinh(t0)];
  prob = coco_prob();
  prob = bvp_isol2seg(prob, '', @catenary, t0, x0, 'Y', cosh(1), ...
    @catenary_bc, @catenary_bc_DFDX);
  prob = coco_add_event(prob, 'UZ', 'Y', [0.6 0.7 1]);
  coco(prob, 'run1', [], 1, 'Y', [0 2]);
end
path(oldpath);
end

function plot_data(db)

bd   = coco_bd_read('run1');
labs = coco_bd_labs(bd, 'UZ');

db.plot_create('chap01_fig05', mfilename('fullpath'));
db.axis([-0.02 1.02 -0.02 1.02]);

lines = {'line1' 'line1g5' 'line1' 'line1' 'line1g5' 'line1'};
idx = 1;
for lab=labs;
  sol = bvp_read_solution('', 'run1', lab);
  db.plot(sol.t, sol.x(:,1), 'numdatal', lines{idx});
  %db.textarrow(sol.x(1,1), sol.x(1,2), 1, sprintf('%d', lab), 'tr', 'lab');
  idx = idx+1;
end
db.xaxis(linspace(0,1,6),2, 0.9, 'x');
db.textbox(0.5, 0.9, 'f', 'tr', 'func');
% db.yaxis(linspace(0,1,6),2, 0.9, 'f(x)');
db.plot_margin([0.01 0.01 0 0]);
db.plot_close();

% align plots
plots = {
  'chap01_fig05' 'chap01_fig06'
  };

% db.plot_align_all_axes(plots);

end
