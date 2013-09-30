function opts = state_locate_cont(opts)
% locate event using Newton's method on extended system

%% initialise xfunc (see also compute_evlist)

ev                    = opts.efunc.ev;
events                = opts.cont.events;

evidx                 = events.evidx;
fixpar_idx            = find(opts.efunc.acp_idx==ev.pidx(evidx),1);
opts.xfunc.fixpar_idx = opts.cont.pidx(fixpar_idx);
opts.xfunc.fixpar_val = ev.vals(evidx);
opts.xfunc.mode       = 1;

%% initialise nwtn

e0 = events.e0;
e1 = events.e1;
u0 = events.u0;
u1 = events.u1;

% compute x0 with Regula Falsi
opts.nwtn.x0       = (abs(e0)*u0+abs(e1)*u1)/(abs(e0)+abs(e1));
opts.nwtn.It       = 0;
opts.nwtn.func     = 'xfunc';
opts.nwtn.LogLevel = opts.cont.LogLevel(2);

%% next state is correct

opts.cont.state      = 'correct';
opts.cont.next_state = opts.cont.locate_add_state;
opts.cont.err_state  = opts.cont.locate_warn_state;
