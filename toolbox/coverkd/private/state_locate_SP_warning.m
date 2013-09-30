function opts = state_locate_SP_warning(opts)

if ~isfield(opts.cont.events, 'evhan')
	pt_type  = opts.efunc.ev.point_type{opts.cont.events.evidx};
	if opts.cont.LogLevel(1)>=2
		fprintf(2, 'warning: error while locating special point of type ''%s''\n', ...
			pt_type);
	end
end

opts.cont.events.state = 'init';
opts.cont.state        = 'locate_events';
