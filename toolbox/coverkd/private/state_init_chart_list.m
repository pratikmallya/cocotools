function opts = state_init_chart_list(opts)
% STATE_INIT  Initialise finite-state machine.
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

%% clear and initialise chart stack

opts             = charts_init(opts);
opts.cont.ptlist = {};

%% initialise headline of opts.bd

[opts opts.bd]     = opts.bddat.init(opts);
opts.cont.next_lab = 1;
opts.bddat.insert  = opts.bddat.append;
opts.cont.branch   = 0;
opts.cont.It       = 0;
opts.xfunc.h       = 0;

%% partially initialise first chart
opts.cont.u0   = opts.nwtn.x;
opts.cont.h0   = min(max(opts.cont.h0, opts.cont.h_min), opts.cont.h_max);
[opts TS]      = coverkd_tangent(opts, opts.cont.u0);
chart          = createChart(opts.cont.k, opts.cont.u0, opts.cont.h0, TS);
chart.x        = chart.center;
[opts chart.p] = opts.efunc.monitor_F(opts, chart.center);
chart.pt_type  = 'EP';

% check if only correction of initial point was requested
if max(opts.cont.ItMX)<=0
	opts                 = print_headline(opts);
	[opts sol]           = save_data(opts, chart);
	opts                 = print_data(opts, sol);
	
	% go straight to predict [which will exit the FSM]
	opts.cont.state      = 'predict';
	return
end

%% check that initial point is interior point

% [opts ev0] = opts.efunc.events_F(opts, chart.x);
% 
% evmask(1:numel(ev0))         = 0;
% evmask(opts.efunc.ev.BP_idx) = 1;
% evmask(opts.efunc.ev.MX_idx) = 2;
% evlist                       = find(evmask)';
% 
% evsign = opts.efunc.ev.evsign(evlist);
% evvals = ev0(evlist)';
% 
% epleft  = evsign=='<' & evvals<=0;
% epright = evsign=='>' & evvals>=0;
% ephits  = epleft | epright;
% epidx   = find(ephits);
% hitnum  = numel(epidx);
% 
% % call event handler if defined to check point
% for i=hitnum:-1:1
% 	evidx = evlist(epidx(i));
% 	evhan = opts.efunc.ev.evhan{evidx};
% 	if ~isempty(evhan)
% 		handata.x     = chart.x;
% 		handata.u0    = chart.x;
% 		handata.u1    = chart.x;
% 		handata.e0    = evvals(epidx(i));
% 		handata.e1    = evvals(epidx(i));
% 		handata.pidx  = opts.efunc.ev.pidx(evidx);
% 		handata.pars  = coco_idx2par(opts, handata.pidx);
% 		handata.evidx = evidx;
% 		[msg handata] = evhan(opts, 'check', handata);
% 		if strcmp(msg.action, 'reject')
% 			hitnum    = hitnum-1;
% 			epidx (i) = [];
% 		end
% 	end
% end
% 
% % hitting one boundary event is allowed, compute direction that
% % leads into computational domain and disable continuation in the
% % other direction
% if hitnum==1 && evmask(evlist(epidx))==1 && abs(evvals(epidx))<=10*opts.nwtn.TOL
% 	evidx = evlist(epidx);
% 	switch opts.efunc.ev.par_type{evidx}
% 		case {'continuation' 'regular'}
% 			% compute directional derivative at boundary
% 			h          = 1.0e-8*( 1.0 + max(abs(chart.x)) );
% 			x0         = chart.x - h * t;
% 			x1         = chart.x + h * t;
% 			[opts ev0] = opts.efunc.events_F(opts, x0);
% 			[opts ev1] = opts.efunc.events_F(opts, x1);
% 			evp        = 0.5*(ev1(evidx)-ev0(evidx))/h;
% 			
% 			% disable continuation leading outside computational domain
% 			if abs(evp)>10*opts.nwtn.TOL
% 				chart.ignore_at = evidx;
% 				hitnum          = 0;
% 				if evsign(epidx)=='<'
% 					if evp>0
% 						opts.cont.ItMX(2) = 0;
% 					else
% 						opts.cont.ItMX(1) = 0;
% 					end
% 				else
% 					if evp>0
% 						opts.cont.ItMX(1) = 0;
% 					else
% 						opts.cont.ItMX(2) = 0;
% 					end
% 				end
% 			end
% 	end
% end
% 
% % exit with error if initial point is outside computational boundary
% if hitnum>=1
% 	epnames = { opts.efunc.ev.point_type{evlist(epidx)} };
% 	epnmsg  = epnames{1};
% 	for i=2:hitnum
% 		epnmsg = [ epnmsg ', ' epnames{i} ]; %#ok<AGROW>
% 	end
% 	error('%s: %s\n%s: %s', mfilename, ...
% 		'initial point is outside computational domain', ...
% 		'active boundary or terminal constraints were', epnmsg);
% end
% 
% if max(opts.cont.ItMX)<=0
%   
%   % empty domain: save and return initial point
%   opts             = print_headline(opts);
%   [opts sol]       = save_data(opts, chart);
%   opts             = print_data(opts, sol);
%   opts.cont.state  = 'predict';
%   return
% end

%% initialise atlas and pop first vertex

opts         = charts_push(opts, chart, 1);
[opts chart] = charts_pop(opts);

if opts.cont.LogLevel(1)>0; fprintf('\n'); end

% initialise covering algorithm
opts.cont.next_lab   = 1;
opts.bddat.insert    = opts.bddat.append;
opts.cont.branch     = 1;

opts.cont.It         = 0;
opts.cont.ptlist     = { chart };
opts.cont.current_pt = 1;
opts                 = print_headline(opts);
[opts sol]           = save_data(opts, chart);
opts                 = print_data(opts, sol);
opts.cont.It         = 1;

%% next state is predict

opts.cont.state = 'predict';
