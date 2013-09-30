function opts = state_locate_special_points(opts)
%STATE_COMPUTE_EVENTS  Locate events in current simplex.
%
%   OPTS = STATE_COMPUTE_EVENTS(OPTS) assigns 'sol' to 'ptlist' and
%   instantiates an empty 'spt' property if necessary. If the maximum
%   number of iterations along the solution branch in the current direction
%   has been reached, then this property is set to 'EP'. (Call to ptlist(1)
%   seems unnecessary). The state is subsequently set to HANDLE_EVENTS.
%
%   To do: This is confusing. Why is ptlist erased here. It was just given
%   a value in check_solution in case the boundary was reached. On the
%   other hand, if the boundary was not reached, ptlist doesn't even exist.
%
%   See also:
%

%% compute list of events

if isempty(opts.efunc.ev.SP_idx)
	opts.cont.state = 'insert_points';
  return;
end

events = opts.cont.events;

[opts events.ev1] = opts.efunc.events_F(opts, events.u0);
[opts events.ev2] = opts.efunc.events_F(opts, events.u1);

evmask(1:numel(events.ev1),1) = 0;
evmask(opts.efunc.ev.SP_idx)  = 1;
evcrossed                     = events.ev1.*events.ev2<=0;
if opts.cont.branch==1
	evignore                    = events.ev1==0;
else
	evignore                    = events.ev2==0;
end
evconst                       = abs(events.ev1-events.ev2)<=10*opts.nwtn.TOL;
evlist        = find(evmask & evcrossed & ~evignore & ~evconst);
events.evlist = reshape(evlist, [1 numel(evlist)]);

opts.cont.events = events;

%% set state variables used by locate algorithms

opts.cont.locate_next_state = 'insert_points';
opts.cont.locate_warn_state = 'locate_SP_warning';
opts.cont.locate_add_state  = 'add_SP';

%% go to next state

if isempty(events.evlist)
	opts.cont.state = opts.cont.locate_next_state;
else
	opts.cont.state = 'locate_events';
end
