function [opts cont corr] = corr_broyden(opts, cont, func)

% get toolbox settings
[opts corr] = get_settings(opts);

% set up Broyden's method
corr.F        = opts.(func).F;
corr.solve    = @solve;
corr.init     = @init;
corr.step     = @step;
corr.set_opts = @set_opts;

opts = coco_add_signal(opts, 'corr_print', 'corr_broyden');

end

function [opts corr] = get_settings(opts)

corr = coco_get(opts, 'corr');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for Broyden's method

defaults.ItMX     = 25      ; % max. number of iterations
defaults.ItMN     = 3       ; % min. number of iterations
defaults.SubItMX  = 4       ; % max. number of damping steps
defaults.MaxStep  = 0.1     ; % max. size of Broyden step
defaults.ga0      = 1.0     ; % initial damping factor
defaults.al       = 0.5     ; % increase damping factor
defaults.lsol     = struct(); % settings for linear solver

corr = coco_merge(defaults, corr);
defaults.ResTOL = corr.TOL ; % convergence criterion ||f(x)||<=ResTOL
corr = coco_merge(defaults, corr);

corr.filter = {'LogLevel' 'TOL' 'ItMX' ...
  'ItMN' 'SubItMX' 'ResTOL' 'MaxStep' 'ga0' 'al' 'lsol'};

end

function corr = set_opts(corr, settings)
corr = coco_merge(corr, settings, corr.filter);
end

%%
function [opts chart x] = solve(opts, chart, x0)

[opts chart accept x] = init(opts, chart, x0);
while ~accept
	[opts chart accept x] =step(opts, chart);
end

end

%%
function [opts chart accept x0] = init(opts, chart, x0)

corr = opts.corr;

corr.x     = x0;
if ~isfield(corr, 'JInv')
  corr.JInv  = eye(numel(x0));
end
corr.It    = 0;
corr.SubIt = 0;
corr.ftm   = 0;

tm                  = clock;
[opts chart corr.f] = corr.F(opts, chart, corr.x);
corr.ftm            = corr.ftm + etime(clock, tm);
corr.norm_f         = norm(corr.f);
corr.accept         = (corr.norm_f<opts.corr.ResTOL);
corr.accept         = corr.accept && (corr.It>=opts.corr.ItMN);

opts.corr = corr;
accept    = corr.accept;

opts = coco_emit(opts, 'corr_begin', 'broyden', chart, corr.x);
opts = print_headline(opts, corr);
opts = print_data    (opts, corr, chart, corr.x);
if accept
  opts = coco_emit(opts, 'corr_end', 'broyden', 'accept', chart, corr.x);
end

end

%%
function [opts chart accept x] = step(opts, chart)

corr = opts.corr;

corr.It = corr.It + 1;

corr.d  = corr.JInv * corr.f;
corr.ga = corr.ga0;
x       = corr.x;
f       = corr.f;
if corr.ga*norm(corr.d) > corr.MaxStep*(1.0+norm(x))
	corr.ga = corr.MaxStep*(1.0+norm(x))/norm(corr.d);
end

for SubIt = 1:corr.SubItMX
	corr.SubIt          = SubIt;
	corr.x              = x - corr.ga * corr.d;
	tm                  = clock;
	[opts chart corr.f] = corr.F(opts, chart, corr.x);
	corr.ftm            = corr.ftm + etime(clock, tm);
	if norm(corr.f) < max(corr.ResTOL, corr.norm_f)
		break;
	end
	corr.ga = corr.al * corr.ga;
end

corr.norm_f = norm(corr.f);
corr.accept = (norm(corr.norm_f) < corr.ResTOL);
corr.accept = corr.accept || (norm(corr.d) < corr.TOL);
corr.accept = corr.accept && (corr.It>=opts.corr.ItMN);

if ~corr.accept
  s = corr.x - x;
  y = corr.f - f;
  B = corr.JInv;
  r = (s'*B*y);
  if r==0
    r = s'*s;
  end
  corr.JInv = B + (s-B*y) * (s'*B) / r;
end

opts.corr = corr;
x         = corr.x;
accept    = corr.accept;

opts                 = print_data(opts, corr, chart, corr.x);
[opts fids stop msg] = coco_emit(opts, 'corr_step', 'broyden', chart, corr.x);
stop                 = cell2mat(stop);

if accept
  opts = coco_emit(opts, 'corr_end', 'broyden', 'accept', chart, corr.x);
elseif ~isempty(stop) && any(stop)
  opts = coco_emit(opts, 'corr_end', 'broyden', 'stop');
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
  opts = coco_emit(opts, 'corr_end', 'broyden', 'fail');
	errmsg.identifier = 'CORR:NoConvergence';
	errmsg.message = sprintf('%s %d %s', ...
		'no convergence of Broyden''s method within', ...
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
%   See also: broyden_print_data
%

coco_print(opts, 2, '\n%8s%10s%20s%10s%7s\n', ...
  'STEP', 'DAMPING', 'NORMS', ' ', 'TIME');
coco_print(opts, 2, ...
  '%4s%4s%10s%10s%10s%10s%7s', 'IT', 'SIT', ...
	'GAMMA', '||d||', '||f||', '||U||', 'F(x)');

opts = coco_emit(opts, 'corr_print', 'init', 2);
coco_print(opts, 2, '\n');

end

%%
function opts = print_data(opts, corr, chart, x)
%NWTN_PRINT_DATA  Print information about Newton's iteration.
%
%   OPTS = NWTN_PRINT_DATA(OPTS) is called after each Newton iteration and
%   prints information its progress. This function calls
%   OPTS.NWTN.PRINT_DATA to allow printing of additional data.
%
%   See also: broyden_print_headline, coco_default_print
%

if corr.It==0
  coco_print(opts, 2, '%4d%4s%10s%10s%10.2e%10.2e%7.1f', ...
    corr.It, '', '', '', norm(corr.f), norm(corr.x), corr.ftm);
else
  coco_print(opts, 2, '%4d%4d%10.2e%10.2e%10.2e%10.2e%7.1f', ...
    corr.It, corr.SubIt, corr.ga, norm(corr.d), norm(corr.f), norm(corr.x), corr.ftm);
end

opts = coco_emit(opts, 'corr_print', 'data', 2, chart, x);
coco_print(opts, 2, '\n');

end
