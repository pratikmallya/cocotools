function opts = coco_add_func(varargin)
%COCO_ADD_FUNC   Add function to system of equations.
%
%   [OPTS XIDX MIDX FIDX] = COCO_ADD_FUNC([OPTS], FID, @FUNC, ...
%       [@DFUNC], DATA, TYPE, [PNAMES,] [OPTIONS ...])
%   adds a new function to the extended continuation problem. OPTS is a
%   continuation options structure. FUNC is the handle of the function and
%   DFUNC the handle of a function computing the linearisation of the
%   function FUNC. If no function for computing the linearisation is
%   present, numerical differentiation is used. TYPE defines how this
%   function is added to the system; see explanation below. PNAMES is a
%   cell array containing a list of names for the parameters associated to
%   a monitor function. This list must have exactly as many names as the
%   dimension of the vector returned by the monitor function.
%
%   The return argument PIDX is an array containing the indices allocated
%   for the parameters associated with the monitor function.
%
%   Valid values for TYPE are:
%
%   'zero' : add the function to the zero problem of the extended
%      continuation problem. The argument PNAMES, if present, must be
%      empty.
%
%   'inactive' : add the function as an embedded monitor function to the
%      extended continuation problem and mark the parameters corresponding
%      to the monitor function as inactive. These parameters act like
%      constants during a continuation, but can be used as primary
%      continuation parameters.
%
%   'active'   : add the function as an embedded monitor function to the
%      extended continuation problem and mark the parameters corresponding
%      to the monitor function as active. These parameters might change
%      during a continuation and will be checked for events. Active
%      parameters can be exchanged for inactive parameters.
%
%   'internal' : add the function as an embedded monitor function to the
%      extended continuation problem and mark the parameters corresponding
%      to the monitor function as internal parameters. Internal parameters
%      are like active parameters with the additional property that they
%      will be exchanged automatically if the user overspecifies
%      continuation parameters, that is, specifies more continuation
%      parameters than the dimension of the solution manifold. Internal
%      parameters will also automatically be added to the screen output
%      during continuation.
%
%   'regular'  : add the function to the set of monitor functions that are
%      excluded from the continuation problem and treat events associated
%      to this function as regular solution points (IFT is satisfied).
%      Parameters corresponding to such functions will be checked for
%      events, but these parameters cannot be used as continuation
%      parameters.
%
%   'singular' : add the function to the set of monitor functions that are
%      excluded from the continuation problem and treat events associated
%      to this function as singular solution points (IFT may be violated).
%      Parameters corresponding to such functions will be checked for
%      events, but these parameters cannot be used as continuation
%      parameters.

%% affected fields in opts:
%
%    opts.efunc.idx2par     - opts.efunc.idx2par{idx} is the name of
%                             parameter idx
%    opts.efunc.user[A|B|C] - userA are differentiable, userB regular and
%                             userB singular monitor functions; these are
%                             structs with the fields
%                             * idx  - indices of associated parameters
%                             * F    - handle to function
%                             * DFDX - handle to function for Jacobian
%    opts.efunc.userA_dim   - Dimension of solution manifold if only userA
%                             monitor functions were used as constraints
%    opts.efunc.[inactive|active|internal|regular|singular]_pars
%                           - arrays of indices of parameters in each class

%% algorithm
%
%  1. Add parameter names to opts.efunc.idx2par
%  2. Add allocated indices of parameters to opts.efunc.[TYPE]_pars
%  3. Add allocated indices of parameters to opts.efunc.user[A|B|C].pidx
%  4. Add function handles to opts.efunc.user[A|B|C].[F|DFDX]

%% parse input arguments
%  varargin = { [OPTS], FID, @FUNC, [@DFUNC], DATA, TYPE, [PNAMES,] [OPTIONS ...] }

% note on semantics of options 'xidx' and 'u0': enabling arbitrary ordering
% could be useful, but leads to a difficult implementation of coco_remesh
% -> check coco_remesh first before making chnges to the current semantics

argidx = 1;

if isempty(varargin{argidx}) || isstruct(varargin{argidx})
	opts   = varargin{argidx};
	argidx = argidx + 1;
else
	opts = [];
end

if ~isfield(opts, 'efunc')
  opts.efunc = efunc_new([]);
end
if ~isfield(opts.efunc, 'identifyers')
  opts.efunc = efunc_new(opts.efunc);
end
efunc = opts.efunc;

fid = varargin{argidx};
coco_opts_tree.check_path(fid);
argidx = argidx + 1;
check_names(['efunc' 'mfunc' efunc.identifyers], fid, 'function');

fhan = varargin{argidx};
if ~isa(fhan, 'function_handle')
  error('%s: argument %d must be a function handle', mfilename, argidx);
end
argidx = argidx + 1;

if isa(varargin{argidx}, 'function_handle')
  dfhan = varargin{argidx};
  argidx = argidx+1;
else
  dfhan = [];
end

data   = varargin{argidx};
type   = lower(varargin{argidx+1});
argidx = argidx + 2;

switch type
  case 'zero'
    assert(efunc.close_level<1, ...
      '%s: zero functions are closed, cannot add function ''%s''', ...
      mfilename, fid);
  case { 'inactive' 'active' 'internal' }
    assert(efunc.close_level<1, ...
      '%s: embedded monitor functions are closed, cannot add function ''%s''', ...
      mfilename, fid);
  case { 'regular' 'singular' }
    assert(efunc.close_level<2, ...
      '%s: monitor functions are closed, cannot add function ''%s''', ...
      mfilename, fid);
end

switch type
  case 'zero'
    funcarray = 'zero';
  case { 'inactive' 'active' 'internal' }
		funcarray = 'embedded';
	case 'regular'
		funcarray = 'regular';
	case 'singular'
		funcarray = 'singular';
	otherwise
		error('%s: type ''%s'' not recognised', mfilename, type);
end
pararray  = sprintf('%s_pars', type);
func.type = type;

switch type
  case 'zero'
    pnum = 0;
    func.pnum   = pnum;
    func.pnames = {};
  case { 'inactive' 'active' 'internal' 'regular' 'singular' }
    pnames = varargin{argidx};
    argidx = argidx+1;
    if ischar(pnames)
      pnames = { pnames };
    end
    pnum   = numel(pnames);
    pnames = reshape(pnames, 1, pnum);
    func.pnum   = pnum;
    func.pnames = pnames;
end

efopts.vFlag     = false;
efopts.chkFlag   = false;
efopts.baseMode  = 1;
efopts.chartMode = 0;
efopts.tanMode   = 0;
efopts.optsMode  = 0;
efopts.x0        = [];
efopts.t0        = [];
efopts.remesh    = [];
efopts.copy      = [];
efopts.requires  = {};

while(argidx<=nargin)
  oarg   = varargin{argidx};
  argidx = argidx + 1;
  oname  = lower(oarg);
  switch oname
    
    case { 'vectorized' 'vectorised' }
      switch lower(varargin{argidx})
        case {'on' true}
          efopts.vFlag = true;
        case {'off' false}
          efopts.vFlag = false;
        otherwise
          error('%s: unrecognized value for option ''%s''', ...
            mfilename, oarg);
      end
      argidx = argidx + 1;
      
    case 't0'
      assert(any(strcmp(type, {'zero' 'inactive' 'active' 'internal'})), ...
        '%s: %s: %s functions cannot define tangent vectors', ...
        mfilename, fid, type);
      efopts.t0 = varargin{argidx};
      argidx = argidx + 1;
      
    case { 'u0' 'x0' }
      assert(any(strcmp(type, {'zero' 'inactive' 'active' 'internal'})), ...
        '%s: %s: %s functions cannot add continuation variables', ...
        mfilename, fid, type);
      efopts.x0 = varargin{argidx};
      argidx = argidx + 1;
      
    case { 'uidx' 'xidx' }
      if strcmpi(varargin{argidx}, 'all')
        % bug: use flag for xidx=all (?)
        efopts.xidx = [];
      elseif isempty(varargin{argidx})
        % bug: handle empty xidx correctly
        if isfield(efopts, 'xidx')
          efopts = rmfield(efopts, 'xidx');
        end
      else
        efopts.xidx = varargin{argidx};
      end
      argidx = argidx + 1;
     
    case { 'f0' 'y0' }
      efopts.f0 = varargin{argidx};
      argidx = argidx + 1;
      
    case { 'fdim' 'ydim' }
      efopts.f0 = zeros(varargin{argidx},1);
      argidx = argidx + 1;
      
    case 'checkderiv'
      efopts.chkFlag = true;
      
    case 'f+df'
      efopts.baseMode = 2;
      
    case 'passchart'
      efopts.chartMode = 2;
      
    case 'passtangent'
      efopts.tanMode = 4;
      
    case {'returnsprob' 'returnsopts'}
      efopts.optsMode = 8;
      
    case 'remesh'
      efopts.remesh = varargin{argidx};
      argidx = argidx + 1;
      
    case 'copy'
      efopts.copy = varargin{argidx};
      argidx = argidx + 1;
      
    case 'requires'
      if iscell(varargin{argidx})
        efopts.requires = varargin{argidx};
      else
        efopts.requires = { varargin{argidx} };
      end
      idx = cellfun(@(x)any(strcmpi(x,efunc.identifyers)),efopts.requires);
      assert(all(idx), '%s: required function ''%s'' not found', ...
        mfilename, efopts.requires{find(~idx,1)});
      argidx = argidx + 1;
      
    otherwise
      if ischar(oarg)
        error('%s: option ''%s'' not recognised', mfilename, oarg);
      else
        error('%s: in argument %d: expected string, got a ''%s''', ...
          mfilename, argidx-1, class(oarg));
      end
  end
end

xnum  = numel(efopts.x0);
tpidx = xnum+(1:pnum);
if isfield(efopts, 'xidx')
  efopts.xidx = efopts.xidx(:)';
  if any(strcmpi(type, { 'zero' 'inactive' 'active' 'internal' }))
    assert(isempty(efopts.xidx) || numel(efopts.xidx)+xnum>0, '%s: %s %s', ...
      mfilename, 'at least one of ''uidx|xidx'' or ''u0|x0''', ...
      'must be present and non-empty');
  end
else
  if any(strcmpi(type, { 'zero' 'inactive' 'active' 'internal' }))
    assert(xnum>0, '%s: %s %s', ...
      mfilename, 'at least one of ''uidx|xidx'' or ''u0|x0''', ...
      'must be present and non-empty');
  end
end

if xnum==0
  % no x0 given
  if isfield(efopts, 'xidx')
    % use xidx, if xidx is empty, efunc_init will assign full solution vector
    xidx = efopts.xidx;
    x0   = efunc.x0(xidx);
    t0   = efunc.tx(xidx);
  else
    % no xidx given, use full x vector constructed so far
    efopts.xidx = efunc.x_idx;
    x0          = efunc.x0;
    t0          = efunc.tx;
  end
  % initialise tangent vector
  if pnum>0
    if isempty(efopts.t0)
      efopts.t0 = zeros(pnum,1);
    else
      efopts.t0 = efopts.t0(:);
    end
  end
else
  % x0 given, amend solution vector
  x0          = efopts.x0(:);
  xidx        = efunc.x_dim+(1:xnum);
  efunc.x0    = [efunc.x0    ; x0  ];
  efunc.x_idx = [efunc.x_idx   xidx];
  efunc.x_dim =  efunc.x_dim + xnum ;
  % construct tangent data from input
  if isempty(efopts.t0)
    % no t0 given
    efopts.t0 = zeros(xnum+pnum,1);
    t0        = zeros(xnum,1);
  else
    % set tangent data from input
    efopts.t0 = efopts.t0(:);
    if numel(efopts.t0)==xnum
      t0        = efopts.t0;
      efopts.t0 = [ t0 ; zeros(pnum,1) ];
    else
      t0        = efopts.t0(1:xnum,1);
    end
  end
  % construct components tx and tp of tangent vector,
  % tp is present for embedded monitor functions and initialises
  % derivatives of internally added parameters
  efunc.tx = [ efunc.tx ; efopts.t0(1:xnum) ];
  % copy solution and tangent data if xidx was given and not empty
  if isfield(efopts, 'xidx')
    if ~isempty(efopts.xidx)
      x0          = [ efunc.x0(efopts.xidx) ; x0];
      t0          = [ efunc.tx(efopts.xidx) ; t0];
      efopts.t0   = [ efunc.tx(efopts.xidx) ; t0];
      tpidx       = numel(efopts.xidx) + tpidx;
      efopts.xidx = [ efopts.xidx xidx ];
    end
  else
    efopts.xidx = xidx;
  end
end

%% create function object and update efunc.f_dim

func.identifyer   = fid;
func.F            = fhan;
func.DFDX         = dfhan;
func.data         = data;
func.x_idx        = efopts.xidx;
func.vectorised   = efopts.vFlag;
func.chkdrv       = efopts.chkFlag;
func.call_mode    = efopts.baseMode + efopts.chartMode ...
  + efopts.tanMode + efopts.optsMode;
func.remesh       = efopts.remesh;
func.copy         = efopts.copy;
func.requires     = efopts.requires;

switch type
  case { 'zero' 'inactive' 'active' 'internal' }
    if efopts.tanMode
      error('%s: error when adding function ''%s'',\n%s', ...
        mfilename, fid, ...
        'tangent can only be passed to regular or singular monitor functions');
    elseif efopts.optsMode
      error('%s: error when adding function ''%s'',\n%s', ...
        mfilename, fid, ...
        'returning ''prob'' only allowed for regular or singular monitor functions');
    end
end

if isfield(efopts, 'f0')
  f = efopts.f0; % don't call F if f0 or fdim given by user
else
  [opts func.data efunc.chart f] = efunc_call_F(opts, func.data, efunc.chart, func, x0, t0);
end

switch type
  case { 'zero' }
    fidx             = efunc.f_dim + (1:numel(f));
    efunc.f_dim      = efunc.f_dim + numel(f);
    efunc.pidx2fidx  = [ efunc.pidx2fidx ; fidx' ];
    efunc.tp(fidx,1) = 0;
  case { 'inactive' 'active' 'internal' }
    fidx             = efunc.f_dim + (1:numel(f));
    efunc.f_dim      = efunc.f_dim + numel(f);
    efunc.pidx2fidx  = [ efunc.pidx2fidx ; fidx' ];
    efunc.tp(fidx,1) = efopts.t0(tpidx);
  otherwise
    fidx            = [];
    efunc.pidx2fidx = [ efunc.pidx2fidx ; zeros(numel(f),1) ];
end
func.f_idx  = fidx;
efunc.f_idx = [efunc.f_idx fidx];

switch type
  case 'zero'
    midx            = [];
    pnames          = cell(1,numel(f));
    efunc.pidx2midx = [ efunc.pidx2midx ; zeros(numel(f),1) ];
  otherwise
    if numel(f)~=pnum
      error('%s: number of parameter names must match dimension of function', ...
        mfilename);
    end
    midx            = efunc.m_dim + (1:numel(f));
    efunc.m_dim     = efunc.m_dim + numel(f);
    efunc.pidx2midx = [ efunc.pidx2midx ; midx' ];
end
func.m_idx          = midx;

func.req_idx = midx;
for i=1:numel(func.requires)
  idx = strcmpi(func.requires{i}, efunc.identifyers);
  efunc.funcs(idx).req_idx = [efunc.funcs(idx).req_idx midx];
end

efunc.funcs       = [ efunc.funcs func ];
efunc.(funcarray) = [ efunc.(funcarray) numel(efunc.funcs) ];
efunc.identifyers = [ efunc.identifyers fid ];

%% add pnames to list of parameters and update efunc.p_dim
%  check for duplicates, add names and compute parameter indices

if pnum>0
  check_names(efunc.idx2par, pnames, 'parameter');
end
idx              = numel(efunc.idx2par) + (1:pnum);
efunc.idx2par    = [ efunc.idx2par pnames ];
efunc.(pararray) = [ efunc.(pararray) idx ];

switch type
	case { 'active' 'internal' }
    efunc.p_dim = efunc.p_dim + pnum;
end

%% return efunc in opts

opts.efunc = efunc;

%% add pending functions

if opts.efunc.add_pending
  opts = coco_add_pending(opts);
end

end

%%
function check_names(list, names, what)
%CHECK_NAMES   check for duplicate names in a list
%
%   CHECK_NAMES(LIST, NAMES, WHAT) throws an error if one of the strings in
%   cell array names is already present in cell array list. The function
%   returns if no duplicates are found. The error message will contain the
%   string WHAT for readability.

if ~iscell(names)
  names = { names };
end

for i=1:numel(names)
  name = names{i};
  if isempty(name)
		error('%s: %s names must not be empty', mfilename, what);
  end
	if any(strcmpi(name, list))
		error('%s: %s with name ''%s'' already defined', mfilename, what, name);
	end
end

end
