function opts = state_locate_events(opts)

events = opts.cont.events;

%% check if we are in a reverse communication loop

if isfield(events, 'evhan')
	
	events.call_count = events.call_count + 1;

	if events.call_count > events.callMX
		fprintf(2, '%s: warning: %s ''@%s'' %s [%d]\n%s: %s\n', ...
			mfilename, 'number of calls to event handler', ...
			func2str(events.evhan), 'exceeded callMX', events.callMX, ...
			mfilename, 'locating events aborted');
		opts.cont.events            = rmfield(events, 'evhan');
		opts.cont.locate_warn_state = events.warn_state;
		opts.cont.locate_add_state  = events.add_state;
		opts.cont.state             = 'locate_events';
		return
	end
			
	switch events.state
	
		case 'init'
			[msg events.handata] = events.evhan(opts, 'init', events.handata);
			
			if events.call_count==1 && isfield(msg, 'callMX')
				events.callMX = msg.callMX;
			end
			
			switch msg.action

				case 'locate'
					events.evidx                = events.evgroup(msg.idx);
					events.point_type           = msg.point_type;
					events.state                = 'check';
					opts.cont.locate_warn_state = events.warn_state;
					opts.cont.locate_add_state  = 'locate_events';
					
				case 'finish'
					opts.cont.events            = rmfield(events, 'evhan');
					opts.cont.locate_warn_state = events.warn_state;
					opts.cont.locate_add_state  = events.add_state;
					opts.cont.state             = 'locate_events';
					return
			end
		
		case 'check'
			events.handata.x     = opts.nwtn.x;
			[msg events.handata] = events.evhan(opts, 'check', events.handata);
			switch msg.action
				
				case 'add'
					events.state                = 'init';
					opts.cont.events            = events;
					opts.cont.locate_warn_state = events.warn_state;
					opts.cont.locate_add_state  = events.add_state;
					opts.cont.state             = events.add_state;
					return
					
				case 'reject'
					events.state                = 'init';
					opts.cont.events            = events;
					opts.cont.locate_warn_state = events.warn_state;
					opts.cont.locate_add_state  = events.add_state;
					opts.cont.state             = 'locate_events';
					return
			end
	end
	
%% initialise new event group

else

%% go to insert_points if all events located

	if isempty(events.evlist)
		opts.cont.state = opts.cont.locate_next_state;
		return
	end

%% compute indices of hit event group

	evlist  = events.evlist;
	evidx   = evlist(1);
	evgroup = opts.efunc.ev.evgroup{evidx};
	evhan   = opts.efunc.ev.evhan{evidx};

	if ~isempty(evgroup)
		evidx = evgroup;
	end

%% remove current event group from event list

	for i=1:numel(evidx)
		evlist(evlist==evidx(i)) = [];
	end

	events.evidx  = evidx;
	events.evlist = evlist;
	
	if ~isempty(evhan)
		handata.u0    = events.u0;
		handata.u1    = events.u1;
		handata.e0    = events.ev1(events.evidx);
		handata.e1    = events.ev2(events.evidx);
		handata.scale = events.scale;
		handata.h     = events.h;
		handata.pidx  = opts.efunc.ev.pidx(evidx);
		handata.pars  = coco_idx2par(opts, handata.pidx);
		handata.evidx = evidx;
		
		events.evhan      = evhan;
		events.handata    = handata;
		events.evgroup    = evidx;
		events.warn_state = opts.cont.locate_warn_state;
		events.add_state  = opts.cont.locate_add_state;
		events.call_count = 0;
		events.callMX     = 100;

		events.state     = 'init';
		opts.cont.state  = 'locate_events';
		opts.cont.events = events;
		return
	end

%% end of check if we are in a reverse communication loop

end

%% set initial values

events.e0  = events.ev1(events.evidx);
events.e1  = events.ev2(events.evidx);
events.v0  = events.u0;
events.h0  = 0;
events.v1  = events.u1;
events.gm  = (1+sqrt(5))/2;
events.la2 = 1/events.gm;
events.la1 = 1-events.la2;

%% dispatch computation of event to appropriate algorithm

if numel(events.evidx)>1
	events.h1       = 1;
	opts.cont.state = 'locate_multi';
else
	switch opts.efunc.ev.par_type{events.evidx}

		case 'continuation'
			opts.cont.state = 'locate_cont';

		case 'regular'

			% initialise subdivision method
			events.h1 = events.dh;

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

		case 'singular'
			events.h1       = 1;
			opts.cont.state = 'locate_sing';
	end
end

%% update opts.events
opts.cont.events = events;
