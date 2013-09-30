function opts = coco_add_event(varargin)
%COCO_ADD_EVENT  Add event to parameter.
%
%   OPTS = COCO_ADD_EVENT([OPTS], EVNAME|(@EVHAN, data, [@copy]), [EVTYPE], SIGNATURE) adds
%   events to the monitor function associated with parameter NAME. Whenever
%   the value of the monitor function crosses one of the values in the
%   array VALUES a special point is located. The type of this special point
%   is set to the string POINT_TYPE. This label can be used to extract
%   special points from the data of a bifurcation diagram.
%
%   Add group events with one monitor and several indicator functions as
%
%     opts = coco_add_event(opts, @evhan_HB, 'test_HB', 0, 'Lyap_HB', nan)
%
%   Lyap_HB will be included in the parameters passed to evhan_HB, but
%   never trigger locating an event.
%
%   SIGNATURE = BP_SIG | MX_SIG | SP_SIG

%% affected fields in opts
%
%    opts.efunc.events - list of events; events are structures with the
%                        fields
%                        * par  - name of parameter the event is attached
%                                 to
%                        * name - name of event (point type)
%                        * vals - array with values for which to detect an
%                                 event
%                        * type - type of event, one of 'boundary' ('BP'),
%                                 'terminal' ('MX') and 'special point'
%                                 ('SP')

%% check for input argument opts
%  varargin = {[opts], evname|(@evhan, data, [@copy]), [evtype], par, values }

argidx = 1;

if isempty(varargin{argidx}) || isstruct(varargin{argidx})
	opts   = varargin{1};
	argidx = argidx + 1;
else
	opts   = [];
end

if ~isfield(opts, 'efunc') || ~isfield(opts.efunc, 'events')
  opts.efunc.events = [];
end

%% parse event name

event_name    = varargin{argidx};
event_handler = [];
event_handata = [];
event_copy    = [];
argidx        = argidx + 1;

if isa(event_name, 'function_handle')
	event_handler = event_name;
	event_name    = func2str(event_handler);
  event_handata = varargin{argidx};
  argidx        = argidx + 1;
  if isa(varargin{argidx}, 'function_handle')
    event_copy  = varargin{argidx};
    argidx      = argidx + 1;
  end
end

%% parse event type
%  define symbol table for signature constructor functions

evtypes = { ...
	'boundary'      @create_BP_signature ; ...
	'BP'            @create_BP_signature ; ...
	'terminate'     @create_MX_signature ; ...
	'MX'            @create_MX_signature ; ...
	'special point' @create_SP_signature ; ...
	'SP'            @create_SP_signature   ...
};

%  check for evtype argument

idx = find(strcmp(varargin{argidx}, evtypes(:,1)), 1);
if isempty(idx)
	create_signature = @create_SP_signature;
else
	create_signature = evtypes{idx,2};
	argidx           = argidx + 1;
end

%  create signature from remaining arguments
%  assign event name, convert to cell array for later expansion using
%  event.name{[1 1 ... 1]}

event      = create_signature(varargin{argidx:end});
event.name = {event_name};
event.han  = event_handler;
event.data = event_handata;
event.copy = event_copy;

%% append event structure to array opts.events

opts.efunc.events = [ opts.efunc.events; event];


%% parse boundary point signatures
function [ SIG ] = create_BP_signature( varargin )
% EP_SIG = PAR (<|>) VAL | SP_SIG

if nargin==3 && ischar(varargin{2}) && any(varargin{2}=='<>')
	SIG.par  = { varargin{1} };
	SIG.sign =   varargin{2}  ;
	SIG.vals =   varargin{3}  ;

	if numel(SIG.vals) ~= 1
		error('%s: vector of values not allowed in ''<''- or ''>'' signatures', ...
			mfilename);
	end
else
	SIG      = create_SP_signature( varargin{:} );
end

SIG.evlist = 'BP_idx';

%% parse terminal point signatures
function [ SIG ] = create_MX_signature( varargin )
% MX_SIG = PAR [<|>|=] VAL

SIG.evlist = 'MX_idx';

if nargin==3 && ischar(varargin{2}) && any(varargin{2}=='<>=')
	SIG.par  = { varargin{1} };
	SIG.sign =   varargin{2}  ;
	SIG.vals =   varargin{3}  ;
elseif nargin==2
	SIG.par  = { varargin{1} };
	SIG.sign =   '='          ;
	SIG.vals =   varargin{2}  ;
else
	error('%s: wrong number or type of arguments', mfilename);
end

if numel(SIG.vals) ~= 1
	error('%s: number of values must be one for terminal events', mfilename);
end

%% parse special point signatures
function [ SIG ] = create_SP_signature( varargin )
% SP_SIG = PAR [=] VALS | (PAR [=] VAL) ...

if nargin<=0
	error('%s: too few arguments', mfilename);
end

SIG.par    = {};
SIG.vals   = [];
SIG.sign   = '';
SIG.evlist = 'SP_idx';
argidx     = 1;

while argidx<=nargin
	if numel(SIG.par)>=1 && numel(SIG.par)~=numel(SIG.vals)
		error('%s: vector of values not allowed in multi-valued signatures', ...
			mfilename);
	end
	
	SIG.par = [ SIG.par varargin{argidx} ];
	argidx  = argidx + 1;

	if nargin<argidx
		error('%s: too few arguments', mfilename);
	end
	if ischar(varargin{argidx})
		if(varargin{argidx}~='=')
			error('%s: ''%s'': illegal event relation', ...
				mfilename, varargin{argidx});
		end
		argidx = argidx + 1;
	end
	SIG.sign = [SIG.sign '='];

	if nargin<argidx
		error('%s: too few arguments', mfilename);
	end
	SIG.vals = [ SIG.vals(:) ; varargin{argidx}(:) ];
	argidx   = argidx + 1;
end

if numel(SIG.par)>1 && numel(SIG.par)~=numel(SIG.vals)
	error('%s: vector of values not allowed in multi-valued signatures', ...
		mfilename);
end
