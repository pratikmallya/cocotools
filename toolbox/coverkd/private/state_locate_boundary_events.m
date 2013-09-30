function opts = state_locate_boundary_events(opts)
%STATE_LOCATE_BOUNDARY_EVENTS  Locate events in current simplex.
%
%   OPTS = STATE_LOCATE_BOUNDARY_EVENTS(OPTS) assigns 'sol' to 'ptlist' and
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

if isempty(opts.efunc.ev.BP_idx)
	opts.cont.state = 'check_terminate_events';
  return;
end

events = opts.cont.events;

[opts events.ev1] = opts.efunc.events_F(opts, events.u0);
[opts events.ev2] = opts.efunc.events_F(opts, events.u1);

evmask(1:numel(events.ev1),1) = 0;
evmask(opts.efunc.ev.BP_idx)  = 1;

if isfield(opts.cont.ptlist{1}, 'ignore_at')
	evmask(opts.cont.ptlist{1}.ignore_at) = 0;
end
if isfield(opts.cont.ptlist{2}, 'ignore_at')
	evmask(opts.cont.ptlist{2}.ignore_at) = 0;
end

evcrossed                     = events.ev1~=0 & events.ev1.*events.ev2<=0;
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

opts.cont.locate_next_state = 'check_terminate_events';
opts.cont.locate_warn_state = 'locate_BP_warning';
opts.cont.locate_add_state  = 'add_BP';

%% go to next state

if isempty(events.evlist)
	opts.cont.state = opts.cont.locate_next_state;
else
	opts.cont.state = 'locate_events';
end

