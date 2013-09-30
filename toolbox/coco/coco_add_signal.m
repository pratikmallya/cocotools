function opts = coco_add_signal(varargin)

% varargin = { [OPTS], NAME, OWNER }

s = coco_stream(varargin{:});

if isempty(s.peek) || isstruct(s.peek)
	opts = s.get;
else
	opts = [];
end

if numel(s)~=2
  error('%s: too many input arguments', mfilename);
end

name  = s.get;
owner = s.get;

signame = lower(name);

if ~isfield(opts, 'signals')
  opts.signals = struct();
end

if isfield(opts.signals, signame)
  error('%s: signal ''%s'' already defined', mfilename, name);
else
  opts.signals.(signame) = struct('name', name, 'owner', owner);
end

end
