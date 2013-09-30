function opts = state_init(opts)
% STATE_INIT  Compute initial point.
%
%   OPTS = STATE_INIT(OPTS) initializes the 'sol' class and the 'u'
%   property of the 'cont' class. The 'sol' class contains information
%   about the solution that is being currently computed, whereas the 'cont'
%   class contains information about the most recently accepted solution?
%   STATE_INIT populates the first column of the 'u' value with the initial
%   state vector and the initial value of the free parameter. This
%   information is copied to the 'u0' property to be used subsequently when
%   restarting the continuation in the opposite direction along the
%   solution branch. The 'p' property is assigned the value of the entire
%   initial parameter vector. A call to a predictor computes the initial
%   tangent vector (using the 'pred.init' property). Subsequently, the
%   current step size and branch direction are initialized. Similarly, the
%   'sol.u', 'sol.p', and 'sol.us' properties are initialized to the
%   corresponding values in the 'cont' class. The 'sol.spt' property is set
%   to 'EP'. The 'cont.next_lab' property is set to 1 and the 'cont.It'
%   property is set to 1. Subsequent to some data logging (this logging
%   sets 'cont.lab' to 1, saves the current solution, the bifurcation data,
%   prints to the screen, empties 'cont.lab' and increments 'cont.next_lab'
%   to 2) and printing, 'cont.It' is set to 2 and the state of the finite
%   state machine is set to 'predict'. 
%
%   See also:
%

%% initialise timer

opts.cont.tm = clock;

%% initialise xfunc

opts.xfunc.fixpar_idx = opts.cont.pidx(1:opts.cont.k);
opts.xfunc.fixpar_val = opts.cont.u0(opts.cont.pidx(1:opts.cont.k));
opts.xfunc.mode       = 3;

%% initialise nwtn

opts.nwtn.x0       = opts.cont.u0;
opts.nwtn.It       = 0;
opts.nwtn.func     = 'xfunc';
opts.nwtn.LogLevel = opts.cont.LogLevel(1);

%% next state is correct

opts.cont.state      = 'correct';
opts.cont.next_state = 'init_chart_list';
opts.cont.err_state  = [];
