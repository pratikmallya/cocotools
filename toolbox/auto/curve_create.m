function opts = curve_create(opts, prefix, f, fx, fp, fdata, x0, p0, tx, tp)

% get toolbox options
defaults.vectorised = false; % is function vectorised
defaults.ParNames   = {}   ; % descriptive parameter names
defaults.no_save    = {}   ; % list of fields not to be saved

tbxid = coco_get_id(prefix,'curve');
copts = coco_get(opts, tbxid);
copts = coco_set(defaults, copts);

% construct toolbox data
data.f       = f;
data.fx      = fx;
data.fp      = fp;
data.fdata   = fdata;
data.prefix  = prefix;
data.no_save = copts.no_save;
data.x_idx   = 1:numel(x0);
data.p_idx   = numel(x0) + (1:numel(p0));

% initialise u0 and t0
u0 = [x0;p0];
if isempty(tx)
  if isempty(tp)
    t0 = [];
  else
    t0 = tp;
  end
else
  if isempty(tp)
    t0 = [ tx ; zeros(numel(p0),1) ];
  else
    t0 = [ tx ; tp ];
  end
end

% add continuation problem (zero problem)
fid = coco_get_id(prefix, 'curve');
if isempty(fx) || isempty(fp)
  opts = coco_add_func(opts, fid, @curve, ...
    data, 'zero', 'x0', u0, 't0', t0, 'vectorised', copts.vectorised );
else
  opts = coco_add_func(opts, fid, @curve, @curve_DFDU, ...
    data, 'zero', 'x0', u0, 't0', t0, 'vectorised', copts.vectorised );
end
data.u_idx = coco_get_func_data(opts, fid, 'xidx');

% define problem parameters
if isempty(prefix)
  fid = coco_get_id(prefix, 'curve_pars');
  if isempty(copts.ParNames)
    opts = coco_add_parameters(opts, fid, data.p_idx, 1:numel(p0));
  else
    opts = coco_add_parameters(opts, fid, data.p_idx, copts.ParNames);
  end
end

% add more output to bifurcation diagram
fid = coco_get_id(prefix, 'curve_bddat');
opts = coco_add_slot(opts, fid, @curve_bddat, data, 'bddat');

% add more output to screen
fid = coco_get_id(prefix, 'curve_print');
opts = coco_add_slot(opts, fid, @curve_print, data, 'cont_print');

% save toolbox data for labelled solution points
fid = coco_get_id(prefix, 'curve_save');
opts = coco_add_slot(opts, fid, @coco_save_data, data, 'save_full');

end

function [data y] = curve(opts, data, u) %#ok<INUSL>
y = data.f(u(data.x_idx), u(data.p_idx), data.fdata{:});
end

function [data J] = curve_DFDU(opts, data, u) %#ok<INUSL>
x = u(data.x_idx);
p = u(data.p_idx);
J = [ data.fx(x,p,data.fdata{:}) data.fp(x,p,data.fdata{:}) ];
end

function [data res] = curve_bddat(opts, data, cmd, chart) %#ok<INUSL>
switch cmd
  case 'init'
    res = coco_get_id(data.prefix, { 'x' 'p' '||x||' });
  case 'data'
    x   = chart.x(data.x_idx);
    p   = chart.x(data.p_idx);
    res = { x p norm(x) };
end
end

function data = curve_print(opts, data, cmd, chart, u) %#ok<INUSL>
switch cmd
  case 'init'
    fprintf('%10s', '||x||');
  case 'data'
    fprintf('%10.2e', norm(u(data.x_idx)));
end
end
