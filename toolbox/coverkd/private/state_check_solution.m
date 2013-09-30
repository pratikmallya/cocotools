function opts = state_check_solution(opts)
%STATE_CHECK_SOLUTION  Check if new solution is acceptable.
%
%   OPTS = STATE_CHECK_SOLUTION(OPTS) If the 'sol.us' property is not yet
%   existent, the tangent vector at the recently found solution is computed
%   and assigned to this property. If the change in direction is too large,
%   the step size is adjusted and the state of the finite-state machine is
%   set to PREDICT, unless the step size is already at its minimum in which
%   case an error message can be output. If the converged parameter value
%   is inside the continuation interval, then the state is set to
%   COMPUTE_EVENTS. 
% 
%   Otherwise, interpolation is applied to estimate a solution on the
%   boundary of the interval and a complete sequence of Newton iterations
%   is performed. If convergence is not achieved, the state is set to
%   REFINE_STEP. Otherwise, the converged solution is assigned to 'sol.u'
%   and 'sol.p' and an interpolated tangent vector is assigned to 'sol.us'.
%   'sol.spt' is given the value 'EP'. The 'sol' class content is assigned
%   to the 'ptlist' class. Finally, the state is set to COMPUTE_EVENTS.
%
%   To do: If statement on line 3 is not really necessary in current
%   implementation. Is the first condition on line 84 really necessary?
%   Let's talk more about the ptlist class.
%
%   See also:
%

%% check angle condition and refine step size if necessary

[opts TS] = coverkd_tangent(opts, opts.nwtn.x);
arc_beta  = subspace(opts.cont.ptlist{1}.TS, TS); % acos(t1' * t2);

% This test is a modification of `arc_beta > opts.cont.arc_alpha' and
% allows for accepting charts with angles somewhat larger than arc_alpha.
% This modification significantly reduces the amount of unnecessarily
% rejected steps.
if arc_beta > opts.cont.h_fac_max * opts.cont.arc_alpha
	
  % reduce step size if possible and repeat continuation step
	if opts.xfunc.h > opts.cont.h_min
    if opts.cont.LogLevel(1) >= 3
      fprintf(2, '%5d * beta [%.4e] > h_fac_max * al_max, refining step size\n', ...
        opts.cont.It, 180 * arc_beta / pi);
    end
    
		opts.xfunc.h = max(opts.cont.h_min, opts.cont.h_fac_min*opts.xfunc.h);
    opts.cont.ptlist{1}.h = opts.xfunc.h;
		opts.cont.state = 'predict';
		return
	
	else % opts.xfunc.h <= opts.cont.h_min
		if opts.cont.LogLevel(1) >= 3
			fprintf(2, '%5d * warning: minimum stepsize reached, but beta [%.4e] > h_fac_max * al_max\n', ...
				opts.cont.It, 180 * arc_beta / pi);
		end
	end
	
end

%% construct new chart from solution

t1 = opts.cont.ptlist{1}.t;
s  = TS'*t1;
t2 = TS*s;
t2 = t2 / norm(t2);

chart   = createChart(opts.cont.k, opts.nwtn.x, opts.cont.ptlist{1}.R, TS);
chart.x = chart.center;
chart.t = t2;

%% check if number of iterations exceeds maximum

if opts.cont.It>=opts.cont.ItMX
	chart.pt_type = 'EP';
	chart.ep_flag = 3;
else
	chart.pt_type = [];
	chart.ep_flag = 0;
end

%% add new chart to point list

[opts chart.p]       = opts.efunc.monitor_F(opts, chart.x);
opts.cont.ptlist     = [ opts.cont.ptlist {chart} ];
opts.cont.current_pt = 2;

%% copy initial data for locate event algorithms to opts.cont.events

events.u0  = opts.cont.ptlist{1}.x;
events.u1  = opts.cont.ptlist{2}.x;
events.us0 = opts.cont.ptlist{1}.t;
events.us1 = opts.cont.ptlist{2}.t;
us         = 0.5*(events.us0+events.us1);
events.us  = us/norm(us);
events.dh  = us'*(events.u1-events.u0);

scale_u0     = 1+norm(events.u0);
scale_u1     = 1+norm(events.u1);
events.scale = 1/max(scale_u0, scale_u1);
events.h     = events.scale*norm(events.u1-events.u0);

[events.A events.B events.C events.D] = ...
	poly_icoeffs(events.u0, events.us0, events.u1, events.us1);

[A B C D] = poly_icoeffs(events.u0/scale_u0, events.us0, ...
	events.u1/scale_u1, events.us1); %#ok<ASGLU>

events.ierr = opts.cont.MEVFac*max(1, norm(2*C+6*D))*events.h*events.h/16;

opts.cont.events = events;

%% partly initialise xfunc locate event algorithms
%  (see also locate_[cont|reg|sing])

opts.xfunc.u0 = events.u0;
% opts.xfunc.t  = events.us';

%% go to locate event algorithms

opts.cont.state = 'locate_boundary_events';
