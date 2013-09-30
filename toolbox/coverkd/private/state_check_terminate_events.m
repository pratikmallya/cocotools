function opts = state_check_terminate_events(opts)
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

%% cut point list to closest end point

opts.cont.ptlist = { opts.cont.ptlist{1:2} };

%% compute list of events

if isempty(opts.efunc.ev.MX_idx)
	opts.cont.state = 'locate_special_points';
  return;
end

events = opts.cont.events;

events.u0         = opts.cont.ptlist{1}.x;
events.u1         = opts.cont.ptlist{2}.x;
[opts events.ev1] = opts.efunc.events_F(opts, events.u0);
[opts events.ev2] = opts.efunc.events_F(opts, events.u1);

evmask(1:numel(events.ev1),1) = 0;
evmask(opts.efunc.ev.MX_idx)  = 1;
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

%% go to next state

if isempty(events.evlist)
	opts.cont.state = 'locate_special_points';
else
	opts.cont.state = 'add_MX';
end
