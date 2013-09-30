function [opts coll x0 s0] = coll_createCollocationSystem(opts, coll, func, seglist, p0)
%Create full collocation system and an initial solution.

% construct collocation system and initial guess over all segments
[opts coll]       = coll_createMeshSegments(opts, coll, seglist, p0);

% combine segment information into full collocation
% system and an initial solution
[opts coll x0 s0] = coll_mergeSegments(opts, coll);

% construct list of right-hand sides and corresponding segments
[opts coll]       = coll_createRHSList(opts, coll, func);
