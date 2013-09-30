function [opts argnum] = coll_sol2sol(opts, prefix, rrun, rlab, varargin)
%coll_ISOL2SOL  Construct boundary value problem and start continuation.
%
%   BD = coll_ISOL2SOL(OPTS, ...) is called by COCO if invoked as
%
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'sol', 'sol', ...
%          BC, RRUN, RLAB, ... )
%
%   coll_SOL2SOL constructs a collocation system and an initial solution
%   for a multi-point boundary value problem (MPBVP) from a previously
%   computed solution.
%
%   Note: This function is mainly provided for convenience of toolbox
%   developers. It allows to check that a specific BVP is set-up correctly.
%

%% process input arguments
% varargin = { }

argnum = 3;

%% load restart data
fid        = coco_get_id(prefix, 'coll');
[data sol] = coco_read_solution(fid, rrun, rlab);

func    = data.func;
seglist = data.sol.seglist;
xidx    = data.xidx;
pidx    = xidx(data.coll.p_idx);
p0      = sol.x(pidx);

%% get collocation settings
coll = coll_get_settings(opts, prefix);

%% construct collocation equations
opts = coll_create(opts, prefix, coll, func, seglist, p0);

