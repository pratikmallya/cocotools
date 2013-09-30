function [opts cont corr] = corr_nwtn(opts, cont, func)

% set up Newton's method
[opts corr] = get_settings(opts);

corr.FDF      = opts.(func).FDF;
corr.solve    = @solve;
corr.init     = @init;
corr.step     = @step;
corr.set_opts = @set_opts;

opts = coco_add_signal(opts, 'corr_print', 'corr_nwtn');

end

%%
function [opts corr] = get_settings(opts)

defaults.ItMX       = 10      ; % max. number of iterations
defaults.ItMN       = 0       ; % min. number of iterations
defaults.ItNW       = []      ; % max. number of full Newton iterations
defaults.SubItMX    = 8       ; % max. number of damping steps
defaults.MaxStep    = 0.1     ; % max. relative size of Newton step
defaults.MaxAbsStep = inf     ; % max. absolute size of Newton step
defaults.MaxAbsDist = inf     ; % max. diameter of trust region
defaults.DampRes    = []      ; % use damping if ||f(x_It)||>DampRes(It)
defaults.DampResMX  = []      ; % use damping if ||f(x)||>DampResMX
defaults.ga0        = 1.0     ; % initial damping factor
defaults.al         = 0.5     ; % increase damping factor

corr                = coco_get(opts, 'corr');
corr                = coco_merge(defaults, corr);

defaults.ResTOL     = corr.TOL; % convergence criteria:
defaults.corrMX     = corr.TOL; %   (||f(x)||<=ResTOL && ||d||<=corrMX)
defaults.ResMX      = corr.TOL; %   (||d||<=TOL && ||f(x)||<=ResMX)

corr                = coco_merge(defaults, corr);

corr.filter = {'LogLevel' 'TOL' 'ItMX' ...
  'ItMN' 'ItNW' 'SubItMX' 'ResTOL' 'corrMX' 'ResMX' 'MaxStep' ...
  'MaxAbsStep' 'MaxAbsDist' 'DampRes' 'DampResMX' 'ga0' 'al' 'lsol'};

end

function corr = set_opts(corr, settings)
corr = coco_merge(corr, settings, corr.filter);
end

%%
function [opts chart x] = solve(opts, chart, x0)

[opts chart accept x] = init(opts, chart, x0);
while ~accept
	[opts chart accept x] = step(opts, chart);
end

end

%%
function [opts chart accept x0] = init(opts, chart, x0)

corr = opts.corr;

corr.x     = x0;
corr.pts   = { x0 };
corr.It    = 0;
corr.SubIt = 0;
corr.ftm   = 0;
corr.dftm  = 0;
corr.stm   = 0;

scale               = 1.0/(1.0+norm(x0));
tm                  = clock;
[opts chart corr.f] = corr.FDF(opts, chart, corr.x);
corr.ftm            = corr.ftm + etime(clock, tm);
corr.norm_f_old     = norm(corr.f);
corr.accept         = (scale*corr.norm_f_old<opts.corr.ResTOL);
corr.accept         = corr.accept && (corr.It>=corr.ItMN);

opts.corr = corr;
accept    = corr.accept;

opts = coco_emit(opts, 'corr_begin', 'nwtn', chart, x0);
opts = print_headline(opts, corr);
opts = print_data    (opts, corr, chart, x0, scale);
if accept
  opts = coco_emit(opts, 'corr_end', 'nwtn', 'accept', chart, x0);
end

end

%%
function [opts chart accept x] = step(opts, chart)

corr = opts.corr;

corr.It = corr.It + 1;

if isempty(corr.ItNW) || corr.It <= corr.ItNW
	tm                         = clock;
	[opts chart corr.f corr.J] = corr.FDF(opts, chart, corr.x);
	corr.dftm                  = corr.dftm + etime(clock, tm);
else
	tm                  = clock;
	[opts chart corr.f] = corr.FDF(opts, chart, corr.x);
	corr.ftm            = corr.dftm + etime(clock, tm);
end

tm                  = clock;
[opts chart corr.d] = opts.lsol.solve(opts, chart, corr.J, corr.f);
corr.stm            = corr.stm + etime(clock, tm);

corr.ga = corr.ga0;
x       = corr.x;
scale   = 1.0/(1.0+norm(x));
if corr.ga*scale*norm(corr.d) > corr.MaxStep
	corr.ga = corr.MaxStep/(scale*norm(corr.d));
end

func = @(z) norm(z - x + corr.ga*corr.d);
dist = min(cellfun(func, corr.pts));
if scale*dist > corr.MaxAbsStep
	corr.ga = corr.MaxAbsStep/(scale*norm(corr.d));
end

func  = @(ga) norm(corr.pts{1} - x + ga*corr.d);
tries = 0;
while scale*func(corr.ga) > corr.MaxAbsDist
	corr.ga = corr.al * corr.ga;
	tries=tries+1;
	if tries>30
		opts = coco_emit(opts, 'corr_end', 'nwtn', 'fail');
		errmsg.identifier = 'CORR:NoConvergence';
		errmsg.message = sprintf('correction leaves trust reagion');
		errmsg.FID = 'NWTN';
		errmsg.ID  = 'MX';
		error(errmsg);
	end
end

if numel(corr.DampRes)<corr.It
  DampResMX = 0;
else
  DampResMX = corr.DampRes(corr.It);
end
if isempty(corr.DampResMX)
  DampResMX = max(DampResMX,corr.ResTOL);
else
  DampResMX = max(DampResMX,corr.DampResMX);
end

for SubIt = 1:corr.SubItMX
	corr.SubIt          = SubIt;
	corr.x              = x - corr.ga * corr.d;
	tm                  = clock;
	[opts chart corr.f] = corr.FDF(opts, chart, corr.x);
	corr.ftm            = corr.ftm + etime(clock, tm);
  accept              = ...
    ( (scale*norm(corr.d) < corr.TOL) && (scale*norm(corr.f) <= corr.ResMX) );
  accept              = accept || ...
    ( (scale*norm(corr.f) < corr.ResTOL) && (scale*norm(corr.d) <= corr.corrMX) );
  accept              = accept || ...
      (scale*norm(corr.f) <= max(scale*corr.norm_f_old, DampResMX));
	if accept
		break;
  end
	corr.ga = corr.al * corr.ga;
end

x               = corr.x;
corr.pts        = [corr.pts x];
corr.norm_f_old = norm(corr.f);
corr.accept     = ...
  ( (scale*norm(corr.d) < corr.TOL) && (scale*norm(corr.norm_f_old) <= corr.ResMX) );
corr.accept     = corr.accept || ...
  ( (scale*norm(corr.norm_f_old) < corr.ResTOL) && (scale*norm(corr.d) <= corr.corrMX) );
corr.accept     = corr.accept && ...
  (corr.It>=corr.ItMN);

opts.corr = corr;
accept    = corr.accept;

opts                 = print_data(opts, corr, chart, x, scale);
[opts fids stop msg] = coco_emit(opts, 'corr_step', 'nwtn', chart, x);
stop                 = cell2mat(stop);

if accept
  opts = coco_emit(opts, 'corr_end', 'nwtn', 'accept', chart, x);
elseif ~isempty(stop) && any(stop)
  opts = coco_emit(opts, 'corr_end', 'nwtn', 'stop');
  emsg = sprintf('%s: stop requested by slot function(s)\n', mfilename);
  for idx=find(stop)
    emsg = sprintf('%s%s: %s\n', emsg, fids{idx}, msg{idx});
  end
	errmsg.identifier = 'CORR:Stop';
	errmsg.message = emsg;
	errmsg.FID = 'NWTN';
	errmsg.ID  = 'MX';
	error(errmsg);
elseif corr.It >= corr.ItMX
  opts = coco_emit(opts, 'corr_end', 'nwtn', 'fail');
	errmsg.identifier = 'CORR:NoConvergence';
	errmsg.message = sprintf('%s %d %s', ...
		'no convergence of Newton''s method within', ...
		corr.ItMX, 'iterations');
	errmsg.FID = 'NWTN';
	errmsg.ID  = 'MX';
	error(errmsg);
end

end

%%
function opts = print_headline(opts, corr)
%NWTN_PRINT_HEADLINE  Print headline for Newton's iteration.
%
%   OPTS = NWTN_PRINT_HEADLINE(OPTS) prints a headline for the iteration
%   information printed for each Newton step. This function calls
%   OPTS.NWTN.PRINT_HEADLINE to allow printing of a headline for
%   additional output data.
%
%   See also: print_data
%

coco_print(opts, 2, '\n%8s%10s%20s%10s%21s\n', ...
  'STEP', 'DAMPING', 'NORMS', ' ', 'COMPUTATION TIMES');
coco_print(opts, 2, '%4s%4s%10s%10s%10s%10s%7s%7s%7s', ...
  'IT', 'SIT', 'GAMMA', '||d||', '||f||', '||U||', 'F(x)', 'DF(x)', 'SOLVE');

opts = coco_emit(opts, 'corr_print', 'init', 2);
coco_print(opts, 2, '\n');

end

%%
function opts = print_data(opts, corr, chart, x, scale)
%NWTN_PRINT_DATA  Print information about Newton's iteration.
%
%   OPTS = NWTN_PRINT_DATA(OPTS) is called after each Newton iteration and
%   prints information its progress. This function calls
%   OPTS.NWTN.PRINT_DATA to allow printing of additional data.
%
%   See also: print_headline, coco_default_print
%

if corr.It==0
  coco_print(opts, 2, ...
    '%4d%4s%10s%10s%10.2e%10.2e%7.1f%7.1f%7.1f', ...
    corr.It, '', '', '', scale*norm(corr.f), norm(corr.x), ...
    corr.ftm, corr.dftm, corr.stm);
else
  coco_print(opts, 2, ...
    '%4d%4d%10.2e%10.2e%10.2e%10.2e%7.1f%7.1f%7.1f', ...
    corr.It, corr.SubIt, corr.ga, ...
    scale*norm(corr.d), scale*norm(corr.f), norm(corr.x), ...
    corr.ftm, corr.dftm, corr.stm);
end

opts = coco_emit(opts, 'corr_print', 'data', 2, chart, x);
coco_print(opts, 2, '\n');

end
