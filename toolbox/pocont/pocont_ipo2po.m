function [opts argnum] = pocont_ipo2po(opts, prefix, varargin)

%% get toolbox settings
[opts pocont] = pocont_get_settings(opts, prefix);

%% create collocation system and use default zero problem
coll_func     = sprintf('%s_isol2sol', pocont.collocation);
coll_func     = str2func(coll_func);
[opts argnum] = coll_func(opts, prefix, varargin{:});

%% set up and initialise boundary conditions
[opts coll xidx] = pocont_add_BC(opts, prefix, pocont);

%% add codim-1 test functions
opts = pocont_add_TF(opts, prefix, pocont, xidx, coll, 1);

%% add external parameters if top-level toolbox
if isempty(prefix)
  opts = coco_add_parameters(opts, prefix, xidx(coll.p_idx), 1:numel(coll.p_idx));
end
