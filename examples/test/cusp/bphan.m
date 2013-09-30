function [ msg data ] = bphan( opts, command, data )
% handle group event [ fold ran ]
%
% we have: LP : fold = 0
%          RN : ran  = 0
%          BP : fold = 0 && ran = 0
%
% data = { u0 u1 e0 e1 scale h evidx pars pidx [check: x t] } + fields added here
% monitor functions: [opts p ] = opts.efunc.monitor_F(opts, data.x);
% event functions:   [opts ev] = opts.efunc.events_F (opts,      p);
% use ev(data.evidx)
%
% NOTE: For boundary events 'check' must be callable without prior call of
%       'init'!

switch command
	
	case 'init'
		
		if ~isfield(data, 'msg')
			% create list of possible events
			data = create_msg_list(opts, data);
			
		elseif strcmp(data.msg.action, 'locate')
			% computation of current event faild
			% remove from list and try next possible event
			data.msgs(data.current_idx).try = 0;
			
		end
		
		% look for event that should be tried to locate
		for i=1:numel(data.msgs)
			if data.msgs(i).try
				data.current_idx = i;
				data.msg         = data.msgs(i);
				msg              = data.msg;
				return;
			end
		end
		
		% no more possible events in list
    % bug: use coco_log/coco_print
		if strcmp(data.msg.action, 'locate') && opts.cont.LogLevel(1)>=2
			fprintf(2, '%s: warning: could not locate special point\n', ...
				mfilename);
		end
		msg.action = 'finish';
		
	case 'check'
		
		% we accept all points if located successfully
		data.msg.action = 'add';
		msg             = data.msg;
		for i=data.msg.mask
			data.msgs(i).try = 0;
		end
		
	otherwise
		error('%s:%s: unknown command', mfilename, command);
end

function data = create_msg_list(opts, data)
evcross = data.e0.*data.e1<=0;
evczero = abs(data.e0-data.e1)<=10*opts.nwtn.TOL;
evczero = evczero & abs(data.e0+data.e1)<=5*opts.nwtn.TOL;
evhits  = evcross | evczero;

% construct lists of possible events
if all(evhits)
	data.msgs(1).idx        = [1 2];
	data.msgs(1).point_type = 'BP';
	data.msgs(1).mask       = [1 2 3];

	data.msgs(2).idx        = 1;
	data.msgs(2).point_type = 'LP';
	data.msgs(2).mask       = [2 3];

	data.msgs(3).idx        = 2;
	data.msgs(3).point_type = 'RN';
	data.msgs(3).mask       = 3;

elseif evhits(1)
	data.msgs(1).idx        = [1 2];
	data.msgs(1).point_type = 'BP';
	data.msgs(1).mask       = [1 2];

	data.msgs(2).idx        = 1;
	data.msgs(2).point_type = 'LP';
	data.msgs(2).mask       = 2;

elseif evhits(2)
	data.msgs(1).idx        = [1 2];
	data.msgs(1).point_type = 'BP';
	data.msgs(1).mask       = [1 2];

	data.msgs(2).idx        = 2;
	data.msgs(2).point_type = 'RN';
	data.msgs(2).mask       = 2;
else
	error('%s: event handler called, but no hits', mfilename);
end

for i=1:numel(data.msgs)
	data.msgs(i).try    = 1;
	data.msgs(i).action = 'locate';
end
