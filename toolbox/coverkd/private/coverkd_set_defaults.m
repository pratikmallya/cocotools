function [opts] = coverkd_set_defaults(defaults, varargin)
% COCO_SET_DEFAULTS  Initialise COCO options for continuation.
%
%   OPTS = COCO_SET_DEFAULTS()
%   OPTS = COCO_SET_DEFAULTS(OPTS) sets a number of default property values
%   of the options structure. Type 'help coco_opts' to see a listing of the
%   various classes and properties set by COCO_SET_DEFAULTS. This function
%   is invoked by COCO.
%
%   See also: coco, coco_set, coco_opts.
%

if nargin<=1
	opts = [];
else
	opts = varargin{2};
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct extended system

opts = coco_set(opts, 'xfunc', 'F',         @xfunc_F);
opts = coco_set(opts, 'xfunc', 'DFDX',      @xfunc_DFDX);
opts = coco_set(opts, 'xfunc', 'func',      'efunc' );
opts = coco_set(opts, 'xfunc', 'linsolve',  defaults.linsolve);
% opts = coco_set(opts, 'xfunc', 'update',    @xfunc_update);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for covering algorithm

opts = coco_set(opts, 'cont', 'MaxRes',    0.1  ); % max. residuum for prediction step
opts = coco_set(opts, 'cont', 'al_max',    7.0  ); % max. angle between two consecutive tangents
opts = coco_set(opts, 'cont', 'h0',        0.1  ); % initial continuation step size
opts = coco_set(opts, 'cont', 'h_max',     0.5  ); % max. continuation step size
opts = coco_set(opts, 'cont', 'h_min',     0.01 ); % min. continuation step size
opts = coco_set(opts, 'cont', 'h_fac_min', 0.5  ); % min. step size adaption factor
opts = coco_set(opts, 'cont', 'h_fac_max', 2.0  ); % max. step size adaption factor
opts = coco_set(opts, 'cont', 'ga',        0.95 ); % adaption security factor
opts = coco_set(opts, 'cont', 'ItMX',      100  ); % max. number of continuation steps
opts = coco_set(opts, 'cont', 'LogLevel',  1    ); % diagnostic output level
opts = coco_set(opts, 'cont', 'NPR',       10   ); % diagnostic output every NPR steps
opts = coco_set(opts, 'cont', 'NSV',       []   ); % save solution every NSV steps, default = NPR, see below
opts = coco_set(opts, 'cont', 'MEVFac',     5   ); % tolerance factor for accepting multiple events

opts = coco_set(opts, 'cont', 'ParIdxMN',  100  ); % smallest index of user-added parameters

opts = coco_set(opts, 'cont', 'efunc',    'efunc'); % non-augmented function to use
opts = coco_set(opts, 'cont', 'xfunc',    'xfunc'); % augmented function to use

opts = coco_set(opts, 'cont', 'corrector',       @coco_nwtn_step);
opts = coco_set(opts, 'cont', 'continuer',       'state');

opts = coco_set(opts, 'cont', 'print_headline',  defaults.print);
opts = coco_set(opts, 'cont', 'print_data',      defaults.print);

opts = coco_set(opts, 'cont', 'save_full',      defaults.save);
opts = coco_set(opts, 'cont', 'save_reduced',   defaults.save);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for finite state machine of continuer

states = {'init' 'init_chart_list' 'predict' 'correct' ...
	'check_solution' 'refine_step' ...
	'locate_boundary_events' 'check_terminate_events' 'locate_special_points' ...
	'locate_BP_warning' 'locate_MX_warning' 'locate_SP_warning' ...
	'add_BP' 'add_MX' 'add_SP' 'locate_events' 'locate_cont' ...
	'locate_reg' 'locate_sing' 'locate_multi' 'insert_points' ...
	'update'};

for i=1:numel(states)
	state = states{i};
	prop  = state;
	han   = str2func(sprintf('state_%s', state));
	opts  = coco_set(opts, 'state', prop, han);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for predictor

opts = coco_set(opts, 'pred', 'init',      @tpred_init);
opts = coco_set(opts, 'pred', 'update',    @tpred_update);
opts = coco_set(opts, 'pred', 'predict',   @tpred_predict);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set defaults for data handling

opts = coco_set(opts, 'bddat', 'init',     @bddat_init);
opts = coco_set(opts, 'bddat', 'append',   @bddat_append);
opts = coco_set(opts, 'bddat', 'prepend',  @bddat_prepend);
