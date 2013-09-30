function opts = state_locate_reg(opts)
% locate event using hybrid subdivision + Newton method

%% evaluate event function at new subdivision point

events     = opts.cont.events;
v          = opts.nwtn.x;
h          = opts.xfunc.h;
e0         = events.e0;
[opts evs] = opts.efunc.events_F(opts, v);
e          = evs(events.evidx);

%% compute new subdivision interval

if e0*e<0
	events.v1 = v;
	events.h1 = h;
	events.e1 = e;
else
	events.v0 = v;
	events.h0 = h;
	events.e0 = e;
end

%% update opts.events

opts.cont.events = events;

%% check convergence

if abs(events.h1-events.h0)/(1+opts.cont.h_max) <= opts.nwtn.TOL
	% go to add_<PointType>
	opts.cont.state = opts.cont.locate_add_state;
	return
end

%% compute new subdivision point

% initialise subdivision method
e0 = events.e0;
e1 = events.e1;

v0 = events.v0;
h0 = events.h0;
v1 = events.v1;
h1 = events.h1;

la1 = events.la1;
la2 = events.la2;

% compute first subdivision point
if abs(e0)<=abs(e1)
	v = la2*v0+la1*v1;
	h = la2*h0+la1*h1;
else
	v = la1*v0+la2*v1;
	h = la1*h0+la2*h1;
end

% initialise xfunc
opts.xfunc.h    = h;
opts.xfunc.mode = 0;

% initialise nwtn
opts.nwtn.x0       = v;
opts.nwtn.It       = 0;
opts.nwtn.func     = 'xfunc';
opts.nwtn.LogLevel = opts.cont.LogLevel(2);

% next state is correct, then go to locate_reg
opts.cont.state      = 'correct';
opts.cont.next_state = 'locate_reg';
opts.cont.err_state  = opts.cont.locate_warn_state;
