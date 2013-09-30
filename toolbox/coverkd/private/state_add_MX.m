function opts = state_add_MX(opts)

%% create boundary chart

ev = opts.efunc.ev;

if isfield(opts.cont, 'events')
	events = opts.cont.events;
else
	events = [];
end

if ~isfield(events, 'evlist')
	events.evlist = [];
end

%% add charts to point list

if isempty(events.evlist)
	chart            = opts.cont.ptlist{1};
	chart.pt_type    = 'MX';
	chart.ep_flag    = 2;
	opts.cont.ptlist = { opts.cont.ptlist{1} chart };
else
	chart              = opts.cont.ptlist{2};
	chart.ep_flag      = 2;

	opts.cont.ptlist   = { opts.cont.ptlist{1} };
	for i=1:numel(events.evlist)
		if isfield(events, 'evhan')
			chart.pt_type  = events.point_type;
		else
			chart.pt_type  = ev.point_type{events.evlist(i)};
		end
		opts.cont.ptlist = { opts.cont.ptlist{:} chart };
	end
end

%% next state is insert_points

opts.cont.state = 'insert_points';
