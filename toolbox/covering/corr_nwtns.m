function [opts cont corr] = corr_nwtns(opts, cont, func)

% set up damped Newton's method
[opts corr] = get_settings(opts);

corr.FDF      = opts.(func).FDF;
corr.solve    = @solve;
corr.init     = @init;
corr.step     = @step;
corr.set_opts = @set_opts;

opts = coco_add_signal(opts, 'corr_print', 'corr_nwtns');

end

%%
function [opts corr] = get_settings(opts)

defaults.ItMX       = 10    ; % max. number of iterations
defaults.SubItMX    = 8     ; % max. number of damping steps
defaults.ga0        = 1.0   ; % initial damping factor
defaults.al         = 0.5   ; % increase damping factor

corr                = coco_get(opts, 'corr');
corr                = coco_merge(defaults, corr);

corr.filter = {'LogLevel' 'TOL' 'ItMX' 'SubItMX' 'ga0' 'al' 'lsol'};

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

corr.It    = 0;
corr.SubIt = 0;
corr.ftm   = 0;
corr.dftm  = 0;
corr.stm   = 0;

opts.corr = corr;
accept    = false;

tm              = clock;
[opts chart f1] = corr.FDF(opts, chart, x0);
corr.ftm        = corr.ftm + etime(clock, tm);

opts = coco_emit(opts, 'corr_begin', 'nwtns', chart, x0);
opts = print_headline(opts, corr);
opts = print_data    (opts, corr, chart, x0, f1, 0, 0);

end

%%
function [opts chart accept x] = step(opts, chart)

corr = opts.corr;

corr.It = corr.It + 1;
x       = chart.x;

tm               = clock;
[opts chart f J] = corr.FDF(opts, chart, x);
corr.dftm        = corr.dftm + etime(clock, tm);

tm             = clock;
[opts chart d] = opts.lsol.solve(opts, chart, J, f);
corr.stm       = corr.stm + etime(clock, tm);

ga = corr.ga0;

for SubIt = 1:corr.SubItMX
	corr.SubIt      = SubIt;
	x               = chart.x - ga * d;
	tm              = clock;
	[opts chart f1] = corr.FDF(opts, chart, x);
	corr.ftm        = corr.ftm + etime(clock, tm);
  
	if norm(f1) <= norm(f); break; end
  
	ga              = corr.al * ga;
end

opts.corr = corr;
accept    = (norm(d) < corr.TOL);

opts                 = print_data(opts, corr, chart, x, f1, d, ga);
[opts fids stop msg] = coco_emit(opts, 'corr_step', 'nwtns', chart, x);
stop                 = cell2mat(stop);

if accept
  opts = coco_emit(opts, 'corr_end', 'nwtns', 'accept', chart, x);
elseif ~isempty(stop) && any(stop)
  opts = coco_emit(opts, 'corr_end', 'nwtns', 'stop');
  emsg = sprintf('%s: stop requested by slot function(s)\n', mfilename);
  for idx=find(stop)
    emsg = sprintf('%s%s: %s\n', emsg, fids{idx}, msg{idx});
  end
	errmsg.identifier = 'CORR:Stop';
	errmsg.message = emsg;
	errmsg.FID = 'NWTNS';
	errmsg.ID  = 'MX';
	error(errmsg);
elseif corr.It >= corr.ItMX
  opts = coco_emit(opts, 'corr_end', 'nwtns', 'fail');
	errmsg.identifier = 'CORR:NoConvergence';
	errmsg.message = sprintf('%s %d %s', ...
		'no convergence of Newton''s method within', ...
		corr.ItMX, 'iterations');
	errmsg.FID = 'NWTNS';
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
function opts = print_data(opts, corr, chart, x, f, d, ga)
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
    corr.It, '', '', '', norm(f), norm(x), corr.ftm, corr.dftm, corr.stm);
else
  coco_print(opts, 2, ...
    '%4d%4d%10.2e%10.2e%10.2e%10.2e%7.1f%7.1f%7.1f', ...
    corr.It, corr.SubIt, ga, norm(d), norm(f), norm(x), ...
    corr.ftm, corr.dftm, corr.stm);
end

opts = coco_emit(opts, 'corr_print', 'data', 2, chart, x);
coco_print(opts, 2, '\n');

end
