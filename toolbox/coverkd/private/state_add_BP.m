function opts = state_add_BP(opts)
% add a new chart to point list

%% construct new chart from special point

ev             = opts.efunc.ev;
events         = opts.cont.events;

chart.x        = opts.nwtn.x;
chart.TS       = opts.xfunc.t';
[opts chart.p] = opts.efunc.monitor_F(opts, chart.x);
if isfield(events, 'evhan')
	chart.pt_type  = events.point_type;
else
	chart.pt_type  = ev.point_type{events.evidx};
end
chart.ep_flag  = 1;

%% insert event ordered by arc length

u0      = events.u0;
t       = events.us;
s0      = t'*(chart.x  -u0);
s1      = t'*(events.u1-u0);
la      = s0/s1;
chart.t = (1-la)*events.us0 + la*events.us1;
chart.t = chart.t/norm(chart.t);

for idx = 1:numel(opts.cont.ptlist)-1
	u1 = opts.cont.ptlist{idx+1}.x;
	s1 = t'*(u1-u0);
	if s0<=s1
		break
	end
end

opts.cont.ptlist = { opts.cont.ptlist{1:idx} chart opts.cont.ptlist{idx+1:end} };

opts.cont.state = 'locate_events';
