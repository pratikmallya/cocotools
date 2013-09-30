function [opts argnum] = mh_imfcont_mf2mf(opts, prefix, rrun, rlab, varargin)

%% process input arguments
% varargin = { }

argnum = 3;

%% read ode function handle
fid  = coco_get_id(prefix, 'func');
func = coco_read_solution(fid, rrun, rlab);

%  re-initialise extended ODE
%  bug: this will become obsolete with improved ODE argument list in coll
imf_create_xode(func);

%% get options
mh_imf = imf_get_settings(opts, prefix);

%% construct collocation system
coll_func = sprintf('%s_sol2sol', mh_imf.collocation);
coll_func = str2func(coll_func);
opts      = coll_func(opts, prefix, rrun, rlab, varargin{:});

%% create BVP
opts = imf_create(opts, prefix, func);
