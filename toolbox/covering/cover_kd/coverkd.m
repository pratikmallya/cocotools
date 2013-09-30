function [opts argnum] = coverkd(opts, varargin)

%% process input arguments
%  varargin = { [dim,] pars, pint }

opts   = coco_set(coverkd_set_defaults(opts.defaults), opts);
argidx = 1;

if ischar(varargin{argidx}) || iscell(varargin{argidx})
  dim    = 1;
else
  dim    = varargin{argidx};
  argidx = argidx + 1;
end

pars   = varargin{argidx  };
pints  = varargin{argidx+1};
argnum = argidx+1;

%% add boundary events

if ischar(pars)
	pars  = { pars  };
end
if ~iscell(pints)
  pints = { pints };
end

for i=1:numel(pints)
  par  = pars {i};
  pint = pints{i};
  if ~isempty(pint)
    opts = coco_add_event(opts, 'EP', 'boundary', par, '<', pint(1));
    opts = coco_add_event(opts, 'EP', 'boundary', par, '>', pint(2));
  end
end

%% adjust and expand maximum number of continuation steps

% % check for empty domain
% if pints{1}(2)<=pints{1}(1) || abs(pints{1}(2)-pints{1}(1))<=opts.nwtn.TOL
% 	opts.cont.ItMX = 0;
% end
% 
% if numel(opts.cont.ItMX)==1
% 	opts.cont.ItMX = [opts.cont.ItMX opts.cont.ItMX];
% end

%% add arclength constraint to continuation problem
data   = coverkd_data();
data.k = dim;
opts = coco_add_func(opts, 'coverkd', @xfunc_F, @xfunc_DFDX, data, ...
  'zero', 'xidx', []);

% bug: this should be moved to data of coverkd
opts.xfunc = data;

% bug: F and DFDX are required by nwtn and should be stored elsewhere
opts.xfunc.F        = opts.efunc.F;
opts.xfunc.DFDX     = opts.efunc.DFDX;
opts.xfunc.linsolve = opts.efunc.linsolve;

%% close system of equations and compute initial solution
[opts u0] = coco_close_efunc(opts, pars);

%% set some variables of the continuer

opts = coco_set(opts, 'cont', 'k',    dim              );
opts = coco_set(opts, 'cont', 'u0',   u0               );
opts = coco_set(opts, 'cont', 'xidx', opts.efunc.x_idx );
opts = coco_set(opts, 'cont', 'pidx', opts.efunc.p_idx );
opts = coco_set(opts, 'cont', 'data', data             );

opts.cont.arc_alpha = opts.cont.al_max * pi / 180;

opts = coco_set(opts, 'coco', 'cont', @fsm_run         );
