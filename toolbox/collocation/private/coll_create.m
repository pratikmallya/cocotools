function [opts xidx coll] = coll_create(opts, prefix, coll, func, seglist, p0)

%% create collocation structure and merged initial solution
[opts coll x0 s0] = coll_createCollocationSystem(opts, coll, func, seglist, p0);

%% call back data
cbdata.func    = func;
cbdata.seglist = seglist;

%% augment collocation system with variational system if required
switch coll.vareqn
	case 'off'
		% add collocation equations to zero problem
    coll.p_idx = numel(x0)+(1:numel(p0))';
    fid        = coco_get_id(prefix, 'coll');
    if isempty(s0)
      opts = coco_add_func(opts, fid, @coll_F, @coll_DFDX, coll, ...
        'zero', 'x0', [x0 ; p0]);
    else
      opts = coco_add_func(opts, fid, @coll_F, @coll_DFDX, coll, ...
        'zero', 'x0', [x0 ; p0], 't0', [s0 ; 0*p0]);
    end
    xidx = coco_get_func_data(opts, fid, 'xidx');

    % add call back functions
    cbdata.xidx = xidx;
    cbdata.coll = coll;
    % fid  = coco_get_id(prefix, 'coll_bddat');
    % opts = coco_add_slot(opts, fid, @coll_bddat, cbdata, 'bddat');
    fid  = coco_get_id(prefix, 'reduced_coll');
    opts = coco_add_slot(opts, fid, @coll_save_reduced,  cbdata, 'save_reduced');
    fid  = coco_get_id(prefix, 'coll');
    opts = coco_add_slot(opts, fid, @coll_save_full,  cbdata, 'save_full');
    % fid  = coco_get_id(prefix, 'coll_print');
    % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'cont_print');
    % fid  = coco_get_id(prefix, 'coll_print');
    % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'corr_print');

	case {'track' 'on'}
		[opts var_seglist] = initVarSol(opts, coll, seglist, x0, p0);
		
		if strcmp(coll.vareqn, 'on')
			% extend collocation system and initial solution
			[opts coll x0] = var_amendCollocationSystem(opts, coll, x0, var_seglist);

			% set functions for collocation problem with multiplier tracking
      coll.p_idx = numel(x0)+(1:numel(p0))';
      fid        = coco_get_id(prefix, 'coll');
      opts       = coco_add_func(opts, fid, @var_F, @var_DFDX, coll, ...
        'zero', 'x0', [x0 ; p0]);
      xidx       = coco_get_func_data(opts, fid, 'xidx');

      % add call back functions
      cbdata.xidx = xidx;
      cbdata.coll = coll;
      % fid  = coco_get_id(prefix, 'coll_bddat');
      % opts = coco_add_slot(opts, fid, @coll_bddat, cbdata, 'bddat');
      fid  = coco_get_id(prefix, 'reduced_coll');
      opts = coco_add_slot(opts, fid, @coll_save_reduced,  cbdata, 'save_reduced');
      fid  = coco_get_id(prefix, 'coll');
      opts = coco_add_slot(opts, fid, @var_save_full,  cbdata, 'save_full');
      % fid  = coco_get_id(prefix, 'coll_print');
      % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'cont_print');
      % fid  = coco_get_id(prefix, 'coll_print');
      % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'corr_print');

		else
			% extend collocation system and initial solution
			[opts coll x0] = var2_amendCollocationSystem(opts, coll, x0, var_seglist);

			% set functions for collocation problem with multiplier tracking
      coll.p_idx = numel(x0)+(1:numel(p0))';
      fid        = coco_get_id(prefix, 'coll');
      opts       = coco_add_func(opts, fid, @var2_F, @var2_DFDX, coll, ...
        'zero', 'x0', [x0 ; p0]);
      xidx       = coco_get_func_data(opts, fid, 'xidx');

      % add call back functions
      cbdata.xidx = xidx;
      cbdata.coll = coll;
      % fid  = coco_get_id(prefix, 'coll_bddat');
      % opts = coco_add_slot(opts, fid, @coll_bddat, cbdata, 'bddat');
      fid  = coco_get_id(prefix, 'reduced_coll');
      opts = coco_add_slot(opts, fid, @coll_save_reduced,  cbdata, 'save_reduced');
      fid  = coco_get_id(prefix, 'coll');
      opts = coco_add_slot(opts, fid, @var2_save_full,  cbdata, 'save_full');
      % fid  = coco_get_id(prefix, 'coll_print');
      % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'cont_print');
      % fid  = coco_get_id(prefix, 'coll_print');
      % opts = coco_add_slot(opts, fid, @coll_print, cbdata, 'corr_print');
      
		end

	otherwise
		error('%s: unrecognised mode ''%s'' for vareqn, %s', mfilename, ...
			coll.vareqn, 'legal values are: ''off'', ''track'' and ''on''');
end

end

function [opts var_seglist] = initVarSol(opts, coll, seglist, x0, p0)
% initialise solution for variational equation

% check if initial solution is given
hasVarISol  = 1;
var_seglist = seglist;
for i=1:numel(var_seglist)
	if ~isfield(var_seglist(i), 'M')
		hasVarISol = 0;
		break
	end
end
if hasVarISol
	return
end

% compute initial solution to variational equation

% copy all settings and set defaults for homotopy
hom_opts = coco_set([], '', coco_get(opts, ''));
hom_opts = coco_set(hom_opts, 'corr', 'ItMX', 1000);
hom_opts = coco_set(hom_opts, 'cont.corr', 'ItMX', 10);
hom_opts = coco_set(hom_opts, 'cont', 'bi_direct', false);
hom_opts = coco_set(hom_opts, 'cont', 'ItMX', 1000);
hom_opts = coco_set(hom_opts, 'cont', 'NPR', 10, 'NSV', 1000);
hom_opts = coco_set(hom_opts, 'cont', 'beta0', 1);
hom_opts = coco_set(hom_opts, 'cont', 'beta_int', [0 1]);

% merge defaults with user settings
hom_opts2 = coco_get(opts, 'cont.hom_opts', '-no-inherit');
hom_opts  = coco_set(hom_opts, '', coco_get(hom_opts2, ''));

% extract initial settings
beta0    = coco_get(hom_opts, 'cont.beta0');
beta_int = coco_get(hom_opts, 'cont.beta_int');

% run homotopy
var_run  = [ coco_run_id(opts) {'var1'} ];
bd_var   = coco(hom_opts, var_run, 'var1', 'isol', 'isol', ...
	coll, x0, p0, beta0, 'beta', beta_int);

% read solution for beta=1
TOL     = coco_get(hom_opts, 'cont.TOL');
bd_type = coco_bd_col(bd_var, 'TYPE');
bd_type = bd_type{end};
beta    = coco_bd_col(bd_var, 'beta');
beta    = beta(end);

if ~strcmp(bd_type, 'EP') || abs(beta-1)>5.0*TOL
	error('%s: could not initialise variational problem', mfilename);
end

ep_lab      = coco_bd_col(bd_var, 'LAB', false);
ep_lab      = ep_lab{end};
sol         = coco_read_solution('coll', var_run, ep_lab);
var_seglist = sol.seglist;
end
