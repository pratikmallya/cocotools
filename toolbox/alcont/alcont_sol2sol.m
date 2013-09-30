function [opts argnum] = alcont_sol2sol(opts, prefix, rrun, rlab, varargin)
%ALCONT_SOL2SOL  Start continuation at previously computed solution.
%
%   BD = ALCONT_SOL2SOL(OPTS, RFNAME, RRUN, RLAB, PNUM, PINT) starts a
%   continuation of solutions of algebraic equations F(X,P)=0. Continuation
%   starts at a solution previously computed with the toolbox ALCONT. The
%   restart solution is uniquely defined by the restart data consisting of
%
%     RFNAME : problem name used in previous computation,
%
%     RRUN   : name of the run the solution was computed in, and
%
%     RLAB   : label that was assigned to the solution.
%
%   The solution is continued with respect to parameter P(PNUM) in the
%   interval PINT(1)<=P(PNUM)<=PINT(1). F is the function passed to COCO as
%   argument NAME. The return value BD is a cell array containing the
%   bifurcation diagram as constructeed by COCO.
%
%   See also: coco, alcont_isol2sol
%

%% process input arguments
%  varargin = {}

argnum = 3;

%% load restart data
fid        = coco_get_id(prefix, 'alcont_save');
[data sol] = coco_read_solution(fid, rrun, rlab);

x    = sol.x(data.xidx);
x0   = x(data.x_idx);
p0   = x(data.p_idx);
clear sol;

%% create instance of toolbox alcont

opts = alcont_create(opts, prefix, data, x0, p0);
