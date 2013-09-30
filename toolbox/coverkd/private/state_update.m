function opts = state_update(opts)
%STATE_UPDATE  Update finite state machine.

%% get end points of arc from ptlist

chart1 = opts.cont.ptlist{1};
chart2 = opts.cont.ptlist{end};

%% step size control: update step size

opts.xfunc.h = chart1.h;

if any(chart2.ep_flag == [0 3])
  arc_beta     = subspace(chart1.TS, chart2.TS); % acos(t1' * t2);
  
  % This if-statement takes care of the case arc_beta==0, which produced an
  % error in some versions of Matlab.
  if opts.cont.h_fac_max^2 * arc_beta < opts.cont.arc_alpha
    h_fac = opts.cont.h_fac_max;
  else
    h_fac = max(opts.cont.h_fac_min, ...
      min(opts.cont.h_fac_max, ...
      opts.cont.arc_alpha / (sqrt(opts.cont.h_fac_max) * arc_beta)));
  end
  
  if opts.cont.LogLevel(1) >= 5
    fprintf(2, 'beta=% .2e[% .2e], h_fac=% .2e, h=% .2e\n', ...
      180 * arc_beta / pi, ...
      180 * opts.cont.h_fac_max * arc_beta / pi, ...
      h_fac, opts.xfunc.h);
  end
  
  % set new step size
  
  opts.xfunc.h = opts.cont.ga * h_fac * opts.xfunc.h;
  opts.xfunc.h = max( min(opts.xfunc.h, opts.cont.h_max), opts.cont.h_min);
  
end

%% check residuum condition for vertices of new hypercube
%  bug(?): redundant chart creation could be removed

if isfield(chart2, 'TS')
  TS = chart2.TS;
else
  TS = chart1.TS;
end

res = chart_hc_res(opts, opts.cont.k, chart2.x, opts.xfunc.h, TS);
while (res > opts.cont.MaxRes) && (opts.xfunc.h > opts.cont.h_min)
	if opts.cont.LogLevel(1) >= 3
		fprintf(2, '%5d * hc_res=%.4e, refining step size\n', ...
			opts.cont.It, res);
  end
  
	opts.xfunc.h = max(opts.cont.h_min, opts.cont.h_fac_min*opts.xfunc.h);
  res = chart_hc_res(opts, opts.cont.k, chart2.x, opts.xfunc.h, TS);
end

%% remesh atlas if necessary

if chart1.h < chart1.R % has step size been reduced?
  if opts.cont.LogLevel(1) >= 4
    tm = tic;
    if isfield(opts.cont, 'rm_count')
      opts.cont.rm_count = opts.cont.rm_count + 1;
    else
      opts.cont.rm_count = 1;
    end
    fprintf(2, 'remeshing atlas [%d] ...\n', opts.cont.rm_count);
  end
  
  opts         = charts_setR(opts, chart1, chart1.h);
  chart1.R     = chart1.h;
  opts.xfunc.h = chart1.h;
  
  if opts.cont.LogLevel(1) >= 4
    fprintf(2, 'remeshing atlas done [%.2fsec]\n', toc(tm));
  end
end

%% add new charts to atlas

R  = chart1.R;
TS = chart1.TS;
hh = ones(1,numel(opts.cont.ptlist))*min(chart1.h,opts.xfunc.h);
hh(end) = opts.xfunc.h;

for i=2:numel(opts.cont.ptlist)
  chart2 = opts.cont.ptlist{i};
  
  if chart2.ep_flag == 2
    continue
  end
  
  if ~isfield(chart2, 'TS')
    chart2.TS = TS;
  end
  
  ca = cos(opts.cont.arc_alpha);
  d  = ca*(chart1.t' * (chart2.x-chart1.x));
  r  = hh(i);
  r  = min([r opts.cont.h_max sqrt(R*R+d*d)]);
  r  = max([r opts.cont.h_min sqrt(R*R-d*d)]);
  
  chart         = createChart(opts.cont.k, chart2.x, r, chart2.TS);
  chart.x       = chart2.x;
  chart.t       = chart2.t;
  chart.pt_type = chart2.pt_type;
  chart.ep_flag = chart2.ep_flag;
  chart.p       = chart2.p;
  opts          = charts_push(opts, chart, any(chart2.ep_flag == [0 3]));
end

%% initialise ptlist with next initial point

opts.cont.It = opts.cont.It+1;
if opts.cont.It<=opts.cont.ItMX
  [opts chart] = charts_pop(opts);
  if isempty(chart)
    opts.cont.ptlist = {};
  else
    opts.cont.ptlist = { chart };
    opts.cont.current_pt = 1;
  end
else
  opts.cont.ptlist = {};
end

%% call back cover_update list
if isfield(opts.cont, 'ptlist') && ~isempty(opts.cont.ptlist)
  chart = opts.cont.ptlist{1};
  x0    = chart.x;
  TS    = chart.TS;
  s     = chart.s;
  h     = chart.h;
  opts  = coco_emit(opts, 'covering_update', 'update', x0, TS, s, h);
end

%% next state is predict
opts.cont.state = 'predict';

end

function res = chart_hc_res(opts, k, x, h, TS)

% ignore residuum of arc-length constraint
opts.xfunc.mode = 2;

% create chart and compute residuum on boundary box
chart = createChart(k, x, h, TS);
xx    = chart.TS*[chart.P.v{:}];
res   = 0;
for i=1:size(xx,2)
  [opts f] = opts.xfunc.F(opts, chart.center+xx(:,i));
  res = max(res,norm(f));
end

end
