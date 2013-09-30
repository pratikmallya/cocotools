function [opts coll argnum seglist] = coll_createInitialSegList(opts, coll, varargin)
%Convert initial data into a list of segments.
%
%   [OPTS ARGIDX] = MPBVP_CREATEINITIALSEGLIST(OPTS, VARARGIN) copies or
%   constructs a list of segments from the initial data provided by the
%   user. The number of arguments processed is returnd in ARGIDX.
%

if isa(varargin{1}, 'function_handle')
	% varargin = {[@]stpnt, ...}
	seglist.stpnt = varargin{1};
	argnum        = 1;
	seglist.fname = [];
	seglist.NTST  = coll.NTST;
	seglist.NCOL  = coll.NCOL;

elseif isstruct(varargin{1})
	% varargin = {seglist, ...}
	seglist = varargin{1};
	argnum  = 1;
	
else
	% varargin = {t0, x0, ...}
	seglist.t0    = varargin{1};
	seglist.x0    = varargin{2};
  if ischar(varargin{3}) && strcmp(varargin{3}, 's0')
    seglist.s0  = varargin{4};
    argnum      = 4;
  else
    argnum      = 2;
  end
	seglist.fname = [];
	seglist.NTST  = coll.NTST;
	seglist.NCOL  = coll.NCOL;
end

