function opts = state_locate_multi(opts)
% use subdivision method to locate event on line segment

events = opts.cont.events;
evnum  = numel(events.evidx);

%% loop over all indices

x = [];

for i=1:evnum

%% initialise subdivision method
	evidx = events.evidx(i);
	
	e0  = events.e0(i);
	e1  = events.e1(i);
	
	% ignore "touching zeros" and constant event functions
	if e0*e1>0 || abs(e1-e0)<=10*opts.nwtn.TOL
		continue
	end

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
		e = evs(evidx);
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

%% end loop over all indices
	x(:,end+1) = v; %#ok<AGROW>
end

%% check if points are close to each other

xnum = size(x,2);

if xnum==0
	opts.cont.state = opts.cont.locate_warn_state;
	return;

elseif xnum==1
	err = 0;
	idx = 1;

else
	o    = ones(1,xnum-1);
	err  = zeros(1,xnum-1);

	for i=1:xnum-1
		idx    = [1:(i-1) (i+1):xnum];
		xx     = x(:,i*o)-x(:,idx);
		err(i) = events.scale * sqrt(max(sum(xx.*xx,1)));
	end

	idx = find(err==min(err),1);
end

%% check if solution is acceptable and go to next state
%  we accept solution if error is less than or equal to
%  10 times the square root of opts.nwtn.TOL; this attempts
%  to honour the quadratic interpolation error

if err(idx) <= events.ierr
	x          = x(:,idx);
	[opts evs] = opts.efunc.events_F(opts, x);
	evs        = events.scale * norm(evs(events.evidx));
	if evs <= events.ierr
		opts.nwtn.x     = x;
		opts.cont.state = opts.cont.locate_add_state;
	else
		opts.cont.state = opts.cont.locate_warn_state;
	end
else
	opts.cont.state = opts.cont.locate_warn_state;
end

events.evidx     = events.evidx(idx);
opts.cont.events = events;
