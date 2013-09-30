function [opts argnum] = bvp_sol2sol(opts, prefix, rrun, rlab, varargin)
%MPBVP_ISOL2SOL  Construct boundary value problem and start continuation.
%
%   BD = MPBVP_ISOL2SOL(OPTS, ...) is called by COCO if invoked as
%
%   BD = COCO(opts, 'mpbvp', NAME, RUN, 'sol', 'sol', ...
%          BC, RRUN, RLAB, ... )
%
%   MPBVP_SOL2SOL constructs a collocation system and an initial solution
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
fid        = coco_get_id(prefix, 'bcnd');
bcnd       = coco_read_solution(fid, rrun, rlab);

%% construct collocation system
opts = coll_sol2sol(opts, prefix, rrun, rlab);

%% construct two-point boundary value problem
opts = bvp_add_BC(opts, prefix, bcnd);
