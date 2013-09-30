function opts = state_predict(opts)
% STATE_PREDICT  Compute a new predicted value.
%
%   OPTS = STATE_PREDICT(OPTS) computes and stores a prediction in 'cont.v'
%   and appropriately initializes the properties of the 'nwtn' class. It
%   also empties the 'sol' class and sets the state of the finite-state
%   machine to CORRECT.
%
%   See also:
%

%% chart list empty? If yes, terminate finite state machine.

if isempty(opts.cont.ptlist)
	opts.cont.accept = 1;
	return
end

%% initialise xfunc

chart           = opts.cont.ptlist{1};
opts.xfunc.u0   = chart.x;
opts.xfunc.t    = chart.TS';
opts.xfunc.s    = chart.s;
opts.xfunc.h    = chart.h;
opts.xfunc.mode = 0;

%% prediction step: compute y = x + h*t

u = chart.x + opts.xfunc.h*chart.t;
[opts f] = opts.xfunc.F(opts, u);
while (norm(f) > opts.cont.MaxRes) && (opts.xfunc.h > opts.cont.h_min)
	if opts.cont.LogLevel(1) >= 3
		fprintf(2, '%5d * norm(f)=%.4e, refining step size\n', ...
			opts.cont.It, norm(f));
  end
  
	opts.xfunc.h = max(opts.cont.h_min, opts.cont.h_fac_min*opts.xfunc.h);
  opts.cont.ptlist{1}.h = opts.xfunc.h;
	u            = chart.x + opts.xfunc.h*chart.t;
	[opts f]     = opts.xfunc.F(opts, u);
end

%% initialise nwtn

opts.nwtn.x0       = u;
opts.nwtn.It       = 0;
opts.nwtn.func     = 'xfunc';
opts.nwtn.LogLevel = opts.cont.LogLevel(2);

%% next state is correct

opts.cont.state      = 'correct';
opts.cont.next_state = 'check_solution';
opts.cont.err_state  = 'refine_step';
