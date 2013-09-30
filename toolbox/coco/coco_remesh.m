function [opts chart x0 V0 all_funcs] = coco_remesh(opts, chart, x0, V0, RMMX)

% return deep copy of functions if requested
if nargout>=5
  all_funcs = coco_save_funcs(opts);
end

if nargin<5
  RMMX = 10;
end

if isempty(V0)
  V0 = zeros(numel(x0),0);
end

% emit remesh signal to tell functions that they will be re-initialised very
% soon, for example, the projection condition shipped with CurveSegmentBase
opts = coco_emit(opts, 'remesh');

%% change all functions and remesh x0 and V0
nfuncs  = numel(opts.efunc.funcs);
old_x0  = x0(opts.efunc.x_idx);
old_V0  = V0(opts.efunc.x_idx,:);
old_x0p = x0(opts.efunc.p_idx);
old_V0p = V0(opts.efunc.p_idx,:);

opts.efunc.chart = chart;
for trial=1:RMMX
  opts   = reset_efunc(opts);
  status = {};
  xtr    = [];
  for i=1:nfuncs
    opts.efunc.cfidx = i;
    func  = opts.efunc.funcs(i);
    x0beg = numel(opts.efunc.x0);
    if isempty(func.remesh)
      if any(numel(func.x_idx) == [0 numel(x0)])
        opts = coco_change_func(opts, func.data, 'xidx', 'all');
      else
        xidx = xtr(func.x_idx(func.x_idx<=numel(xtr)));
        if any(xidx<=0)
          error('%s: compulsory variables have been removed, cannot relocate ''%s''', ...
            mfilename, func.identifyer);
        end
        x0idx = func.x_idx(func.x_idx>numel(xtr));
        if isempty(xidx)
          opts = coco_change_func(opts, func.data, 'x0', old_x0(x0idx), ...
            'vecs', old_V0(x0idx,:));
        else
          opts = coco_change_func(opts, func.data, 'xidx', xidx, 'x0', old_x0(x0idx), ...
            'vecs', old_V0(x0idx,:));
        end
        xtr    = [ xtr ; x0beg+(1:numel(x0idx))' ]; %#ok<AGROW>
      end
      status = [ status 'success' ]; %#ok<AGROW>
    else
      x0idx       = func.x_idx;
      [opts s tr] = func.remesh(opts, func.data, chart, old_x0(x0idx), old_V0(x0idx,:));
      status      = [ status s ]; %#ok<AGROW>
      xtr         = [ xtr ; x0beg+tr(:) ]; %#ok<AGROW>
    end
  end
  success = strcmp('success', status);
  fail    = strcmp('fail'   , status);
  retry   = strcmp('repeat' , status);
  idx     = find(~(success | fail | retry));
  if any(idx)
    emsg = sprintf('%s: remesh function(s) returned illegal status:', mfilename);
    for i=idx
      emsg = sprintf('%s\n%s returned with ''%s''', ...
        emsg, opts.efunc.funcs(i).identifyer, status{i});
    end
    error(emsg);
  end
  old_x0 = opts.efunc.x0;
  old_V0 = opts.efunc.V0;
  accept = all(success);
  if accept || any(fail)
    break
  end
end
if ~accept
  emsg = sprintf('%s: remeshing failed:', mfilename);
  for i = find(fail | retry)
    emsg = sprintf('%s\n%s returned with status ''%s'' after %d trials', ...
      emsg, opts.efunc.funcs(i).identifyer, status{i}, RMMX);
  end
  error(emsg);
else
  coco_log(opts, 1, 1, '%s: mesh accepted after %d trials\n', ...
    mfilename, trial);
end
x0 = [ old_x0 ; old_x0p ];
V0 = [ old_V0 ; old_V0p ];

%% reclose efunc
efunc        = opts.efunc;
cont_pars    = efunc.cont_pars;
cont_par_idx = coco_par2idx(opts, cont_pars, 'sloppy');

%% compute number of parameters to activate
% ppnum = m + d - n, m+d=efunc.f_dim, n = efunc.x_dim+efunc.p_dim
ppnum = efunc.f_dim-(efunc.x_dim+efunc.p_dim);

%% create copy of indices of potential continuation parameters
pararrays = { 'inactive_pars' 'active_pars' 'internal_pars' };

for i = 1:numel(pararrays)
	tmp.(pararrays{i}) = efunc.(pararrays{i});
end

%% exchange parameters as defined with coco_xchg_pars
if isfield(efunc, 'xchg')
	xchg = coco_par2idx(opts, efunc.xchg);
	tmp  = exchange_pars(tmp, pararrays, xchg);
end

%% exchange internal parameters
pnum  = numel(cont_pars);         % number of parameters passed as argument
ipnum = numel(tmp.internal_pars); % number of internal pars
ipend = min(ipnum, pnum-ppnum);   % exchange internal parameters 1:ipend

if pnum>ppnum % more cont_pars than required -> exchange internal parameters
	xchg = [];
	for i = 1:ipend
		idx1 = tmp.internal_pars(i);
		idx2 = cont_par_idx(ppnum+i);
		xchg = [ xchg ; idx1 idx2 ]; %#ok<AGROW>
	end
	tmp = exchange_pars(tmp, pararrays, xchg);
end

%% compute subset of inactive parameters of argument cont_pars
inactive_cont_par_idx = [];
for idx = cont_par_idx
	if any(tmp.inactive_pars == idx)
    inactive_cont_par_idx = [ inactive_cont_par_idx idx ]; %#ok<AGROW>
	end
end
cpnum = numel(inactive_cont_par_idx); % number of inactive cont_pars

if cpnum<ppnum
	% we have more equations than variables+parameters
  errmsg = sprintf('%s: cannot close equations, too few parameters activated?\n', mfilename);
  errmsg = sprintf('%snumber of parameters to activate   : %d\n', errmsg, ppnum);
  errmsg = sprintf('%snumber of inactive parameters given: %d', errmsg, cpnum);
	error(errmsg); %#ok<SPERR>
end

%% activate ppnum inactive parameters

tmp.primary_pars = inactive_cont_par_idx(1:ppnum);
% for i = 1:ppnum
% 	% verify that cont_par_idx(1:ppnum) are now inactive
% 	if isempty(find(tmp.inactive_pars == cont_par_idx(i), 1))
% 		error('%s: too few inactive parameters specified for continuation', ...
% 			mfilename);
% 	end
% 	add parameter to list primary_pars
% 	tmp.primary_pars = [ tmp.primary_pars inactive_cont_par_idx(i)];
% end

efunc.acp_idx = [ ...
	inactive_cont_par_idx(1:ppnum) ...
	tmp.internal_pars ...
	tmp.active_pars ];
efunc.acp_f_idx = efunc.pidx2fidx(efunc.acp_idx);

%% check for duplicate active continuation parameters

for i=1:numel(efunc.acp_idx)
	idx = find(efunc.acp_idx == efunc.acp_idx(i));
	if numel(idx) ~= 1
		error('%s: duplicate continuation parameter ''%s''', ...
			mfilename, efunc.idx2par{efunc.acp_idx(i)});
	end
end

%% create list of parameters for screen output

efunc.op_idx = [ cont_par_idx(1:ppnum) ...
  tmp.internal_pars(ipend+1:end) cont_par_idx(ppnum+1:end) ];

%% create permutation vector for xp

efunc.p_idx  = efunc.x_dim+(1:efunc.p_dim+ppnum);
efunc.xp_idx = [efunc.x_idx efunc.p_idx];
efunc.xp_dim = efunc.x_dim+efunc.p_dim+ppnum;

%% create event structure efunc.ev

ev.pidx       = [];
ev.midx       = [];
ev.par_type   = {};
ev.vals       = [];
ev.point_type = {};
ev.evgroup    = {};
ev.idx        = [];
ev.evsign     = '';
ev.BP_idx     = [];
ev.MX_idx     = [];
ev.SP_idx     = [];

% create copy of indices of remaining parameters
pararrays = { 'regular_pars' 'singular_pars' };
for i = 1:numel(pararrays)
	tmp.(pararrays{i}) = efunc.(pararrays{i});
end

% we ignore events in inactive parameters since these remain constant,
% but include primary continuation parameters
pararrays = { 'primary_pars' 'active_pars' 'inactive_pars' ...
  'internal_pars' 'regular_pars' 'singular_pars' };
partypes  = { 'continuation' 'continuation' 'continuation'  ...
	'continuation'  'regular'      'singular' };

if isfield(efunc, 'events')
  events = efunc.events;
else
	events = [];
end

evnum = 0;

for i=1:numel(events)
	
	% look for parameters name in idx2par
	pars = events(i).par;
	pidx = [];
	for j=1:numel(pars)
		idx = find( strcmp(pars{j}, efunc.idx2par), 1 );
		if isempty(idx)
			error('%s: parameter ''%s'' not found, cannot add events', ...
				mfilename, pars{j});
		end
		pidx = [ pidx ; idx ]; %#ok<AGROW>
	end
	
	% compute type of event parameters
	ptype = {};
	for j=1:numel(pidx)
		type = {};
		for k=1:numel(pararrays)
			if ~isempty(find(tmp.(pararrays{k})==pidx(j),1))
				type = partypes{k};
				break
			end
		end
		if isempty(type)
			ptype = {};
			break;
		else
			ptype = [ ptype type ]; %#ok<AGROW>
		end
	end
	if isempty(ptype)
		continue
	end

	vals       = events(i).vals;
	vnum       = numel(vals);
	evidx      = evnum+(1:vnum);
	point_type = events(i).name;
	evgroup    = {[]};
	evsign     = events(i).sign;
	idx        = i;

	% expand arrays to match size of vals
	o            = ones(vnum, 1);
	point_type   = { point_type{o} };
	if numel(pidx)==1
		pidx       =   pidx(o);
		ptype      = { ptype{o}   };
		evsign     =   evsign(o)';
	else
		evgroup    = { evidx       };
	end
	evgroup      = { evgroup{o}  };
	idx          =   idx(o);

	% update entries in event structure
	ev.pidx       = [ ev.pidx         ; pidx                  ];
  ev.midx       = [ ev.midx         ; efunc.pidx2midx(pidx) ];
	ev.par_type   = [ ev.par_type       ptype                 ];
	ev.vals       = [ ev.vals         ; vals                  ];
	ev.point_type = [ ev.point_type     point_type            ];
	ev.evgroup    = [ ev.evgroup        evgroup               ];
	ev.evsign     = [ ev.evsign         evsign                ];
	ev.idx        = [ ev.idx          ; idx                   ];
	
	evlist      = events(i).evlist;
	ev.(evlist) = [ev.(evlist) evidx];

	evnum       = evnum + vnum;
end

efunc.ev   = ev;
opts.efunc = efunc;

% bug: remove argument chart and pass translation table ytr instead
[opts chart] = efunc_remesh(opts, chart, x0);

end

%% local functions
function opts = reset_efunc(opts)
opts.efunc.x0        = [];
opts.efunc.V0        = [];
opts.efunc.x_dim     =  0;
opts.efunc.p_dim     =  0;
opts.efunc.f_dim     =  0;
opts.efunc.m_dim     =  0;
opts.efunc.x_idx     = [];
opts.efunc.f_idx     = [];
opts.efunc.pidx2midx = [];
opts.efunc.pidx2fidx = [];
opts.efunc.idx2par   = {};
pararrays = { 'zero_pars' 'inactive_pars' 'active_pars' 'internal_pars' ...
  'regular_pars' 'singular_pars' };
for i = 1:numel(pararrays)
  opts.efunc.(pararrays{i}) = [];
end
end

function tmp = exchange_pars(tmp, pararrays, xchg)

for i=1:size(xchg,1)

	for j=1:numel(pararrays)
		old_pararray = pararrays{j};
		old_pidx = find(tmp.(old_pararray)==xchg(i,1));
		if ~isempty(old_pidx); break; end
	end
	
	for j=1:numel(pararrays)
		new_pararray = pararrays{j};
		new_pidx = find(tmp.(new_pararray)==xchg(i,2));
		if ~isempty(new_pidx); break; end
	end
	
	pidx = tmp.(old_pararray)(old_pidx);
	tmp.(old_pararray)(old_pidx) = tmp.(new_pararray)(new_pidx);
	tmp.(new_pararray)(new_pidx) = pidx;
  
end

end
