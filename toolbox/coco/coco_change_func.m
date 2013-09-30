function opts = coco_change_func(opts, data, varargin)

%% parse input arguments
%  varargin = { OPTIONS ... }
%  OPTIONS  = 'x0' x0 | 'vecs' V0 | 'xidx' xidx

efunc = opts.efunc;
func  = efunc.funcs(opts.efunc.cfidx);
type  = func.type;

pararray = sprintf('%s_pars', type);

switch type
  case 'zero'
    pnum = 0;
  case { 'inactive' 'active' 'internal' 'regular' 'singular' }
    pnum   = func.pnum;
    pnames = func.pnames;
end

efopts.x0 = [];
efopts.V0 = [];
xname     = 'u0';

argidx = 1;
while(argidx+2<=nargin)
  oarg   = varargin{argidx};
  argidx = argidx + 1;
  oname  = lower(oarg);
  switch oname
    
    case { 'u0' 'x0' }
      xname     = oarg;
      efopts.x0 = varargin{argidx};
      argidx    = argidx + 1;
      
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
      
    case 'vecs'
      efopts.V0 = varargin{argidx};
      argidx    = argidx + 1;
      
    otherwise
      if ischar(oarg)
        error('%s: option ''%s'' not recognised', mfilename, oarg);
      else
        error('%s: in argument %d: expected string, got a ''%s''', ...
          mfilename, argidx-1, class(oarg));
      end
  end
end

xnum = numel(efopts.x0);
if numel(efopts.x0)~=size(efopts.V0,1)
  emsg = sprintf('%s:', mfilename);
  emsg = sprintf('%s dimension of vectors in vecs [%d] does not', ...
    emsg, size(efopts.V,1));
  emsg = sprintf('%s\nagree with dimension of %s [%d]', ...
    emsg, xname, xnum);
  error(emsg); %#ok<SPERR>
end

if isfield(efopts, 'xidx')
  efopts.xidx = efopts.xidx(:)';
end

if xnum==0
  % no x0 given
  if isfield(efopts, 'xidx')
    % use xidx, if xidx is empty, efunc_init will assign full solution vector
    xidx = efopts.xidx;
    x0   = efunc.x0(xidx);
  else
    % no xidx given, use full x vector constructed so far
    efopts.xidx = efunc.x_idx;
    x0          = efunc.x0;
  end
else
  % x0 given, amend solution vector
  x0          = efopts.x0(:);
  xidx        = efunc.x_dim+(1:xnum);
  efunc.x0    = [efunc.x0    ; x0        ];
  efunc.V0    = [efunc.V0    ; efopts.V0 ];
  efunc.x_idx = [efunc.x_idx   xidx];
  efunc.x_dim =  efunc.x_dim + xnum ;
  % combine solution data if xidx was given and not empty
  if isfield(efopts, 'xidx')
    if ~isempty(efopts.xidx)
      x0          = [ efunc.x0(efopts.xidx) ; x0];
      efopts.xidx = [ efopts.xidx xidx ];
    end
  else
    efopts.xidx = xidx;
  end
end

%% create function object and update efunc.f_dim

func.data  = data;
func.x_idx = efopts.xidx;

switch type
  case 'zero'
    [opts func.data efunc.chart f] = efunc_call_F(opts, func.data, efunc.chart, func, x0);
  otherwise
    f = zeros(pnum,1);
end

switch type
  case { 'zero' 'inactive' 'active' 'internal' }
    fidx             = efunc.f_dim + (1:numel(f));
    efunc.f_dim      = efunc.f_dim + numel(f);
    efunc.pidx2fidx  = [ efunc.pidx2fidx ; fidx' ];
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

efunc.funcs(opts.efunc.cfidx) = func;

%% add pnames to list of parameters and update efunc.p_dim

idx              = numel(efunc.idx2par) + (1:pnum);
efunc.idx2par    = [ efunc.idx2par pnames ];
efunc.(pararray) = [ efunc.(pararray) idx ];

switch type
	case { 'active' 'internal' }
    efunc.p_dim = efunc.p_dim + pnum;
end

%% return efunc in opts

opts.efunc = efunc;

end
