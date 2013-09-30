function opts = state_refine_step(opts)
%STATE_REFINE_STEP  Refine continuation step size.
%
%   OPTS = STATE_REFINE_STEP(OPTS) sets the 'cont.spt' property to 'MX' in
%   case that the minimum step-size is reached. In this case, the state of
%   the finite-state machine is set to 'handle_boundary'. If not, then the
%   step size is adjusted and the state is set to 'predict'.
%
%   See also:
%

if opts.xfunc.h <= opts.cont.h_min
	opts.cont.state = 'add_MX';
	return;
end

opts.xfunc.h = max(opts.cont.h_min, opts.cont.h_fac_min * opts.xfunc.h);
opts.cont.ptlist{1}.h = opts.xfunc.h;

if opts.cont.LogLevel(1) >= 3
	fprintf(2, 'NWTN: no convergence, retry with step size h = % .2e\n', ...
		opts.xfunc.h);
end

opts.cont.state = 'predict';
