function opts = alcont_create(opts, prefix, data, x0, p0)

%% add zero problem

fid = coco_get_id(prefix, 'alcont');
if isempty(data.F)
  opts = coco_add_func(opts, fid, @empty_F, @empty_DFDX, data, 'zero', ...
    'x0', [x0 ; p0]);
else
  opts = coco_add_func(opts, fid, @func_F, @func_DFDX, data, 'zero', ...
    'x0', [x0 ; p0]);
end
xidx = coco_get_func_data(opts, fid, 'xidx');

%% add external parameters if top-level toolbox

fid = coco_get_id(prefix, 'alcont_pars');
if isempty(prefix)
  opts = coco_add_parameters(opts, fid, xidx(data.p_idx), 1:numel(p0));
end

%% initialise output callbacks

cbdata        = data;
cbdata.xidx   = xidx;
cbdata.prefix = prefix;

fid  = coco_get_id(prefix, 'alcont_bddat');
opts = coco_add_slot(opts, fid, @alcont_bddat, cbdata, 'bddat');
fid  = coco_get_id(prefix, 'alcont_save');
opts = coco_add_slot(opts, fid, @coco_save_data, cbdata, 'save_full');
fid  = coco_get_id(prefix, 'alcont_cont_print');
opts = coco_add_slot(opts, fid, @alcont_print, cbdata, 'cont_print');
fid  = coco_get_id(prefix, 'alcont_corr_print');
opts = coco_add_slot(opts, fid, @alcont_print, cbdata, 'corr_print');

end

%% empty default functions

function [data f] = empty_F(opts, data, xp) %#ok<INUSD,INUSL>
f = [];
end

function [data J] = empty_DFDX(opts, data, xp) %#ok<INUSL>
J = sparse(0, numel(xp));
end

%% alcont zero problem

function [data f] = func_F(opts, data, xp) %#ok<INUSL>
%FUNC_F  Evaluate F at XP=[X;P].
%
%   [OPTS F] = FUNC_F(OPTS, XP) calls the function passed as argument
%   NAME to COCO.
%
%   See also: FUNC_DFDX, FUNC_G
%

x = xp(data.x_idx,1);
p = xp(data.p_idx,1);
f = data.F(x, p);
end

function [data J] = func_DFDX(opts, data, xp) %#ok<INUSL>
%FUNC_DFDX  Evaluate Jacobian DF/DXP at XP=[X;P].
%
%   [OPTS J] = FUNC_DFDX(OPTS, XP) computes the Jacobian of the function
%   passed as argument NAME to COCO.
%
%   See also: FUNC_F, FUNC_G, FUNC_DGDX
%

x = xp(data.x_idx,1);
p = xp(data.p_idx,1);

if isempty(data.DFDX)
	if data.vectorised
		J1 = coco_num_DFDXv(data.F, x, p);
	else
		J1 = coco_num_DFDX (data.F, x, p);
	end
else
	J1 = data.DFDX(x, p);
end

if isempty(data.DFDP)
  pars = 1:numel(p);
	if data.vectorised
		J2 = coco_num_DFDPv(data.F, x, p, pars);
	else
		J2 = coco_num_DFDP (data.F, x, p, pars);
	end
else
	J2 = data.DFDP(x, p);
end

J = sparse([J1 J2]);
end

%% alcont call back functions

function [data res] = alcont_bddat(opts, data, command, sol) %#ok<INUSL>
%BDDAT_USR_INIT  Headings for additional data in bifurcation diagram.
%
%   [OPTS HEADINGS] = BDDAT_USR_INIT(OPTS) includes the headings 'X' and
%   'PARS' into the list of headings for the bifurcation diagram.
%

switch command
  case 'init'
    res = coco_get_id(data.prefix, { 'X', 'PARS' });
  case 'data'
    x   = sol.x(data.xidx);
    res = { x(data.x_idx) x(data.p_idx) };
end
end

function data = alcont_print(opts, data, command, chart, x) %#ok<INUSL>
%BDDAT_USR_INIT  Headings for additional data in bifurcation diagram.
%
%   [OPTS HEADINGS] = BDDAT_USR_INIT(OPTS) includes the headings 'X' and
%   'PARS' into the list of headings for the bifurcation diagram.
%

switch command
  case 'init'
    fprintf('%10s', '||x||');
  case 'data'
    fprintf('%10.2e', norm(x(data.x_idx),2));
end
end
