function opts = state_locate_warning(opts)


if opts.cont.LogLevel(1)>=2
	fprintf('%5d * warning: error while locating event of type ''%s''\n', ...
		opts.cont.It, opts.efunc.ev.point_type{evidx});
end

opts.cont.state = 'locate_events';
