function opts = state_locate_sing(opts)
% use subdivision method to locate event on line segment

%% initialise subdivision method

events = opts.cont.events;

e0  = events.e0;
e1  = events.e1;

h0  = events.h0;
h1  = events.h1;

la1 = events.la1;
la2 = events.la2;

%% compute first subdivision point

if abs(e0)<=abs(e1)
	h = la2*h0+la1*h1;
else
	h = la1*h0+la2*h1;
end
v = poly_eval(events.A, events.B, events.C, events.D, h);

%% locate special point

while norm(h1-h0)/(1+opts.cont.h_max) >= opts.nwtn.TOL
	[opts evs] = opts.efunc.events_F(opts, v);
	e = evs(events.evidx);
	if e==0; break; end
	if e0*e<0
		h1 = h;
		e1 = e;
	else
		h0 = h;
		e0 = e;
	end
	if abs(e0)<=abs(e1)
		h = la2*h0+la1*h1;
	else
		h = la1*h0+la2*h1;
	end
	v = poly_eval(events.A, events.B, events.C, events.D, h);
end

%% use opts.nwtn.x to return new point

opts.nwtn.x = v;

%% next state is add_<PointType>

opts.cont.state = opts.cont.locate_add_state;
