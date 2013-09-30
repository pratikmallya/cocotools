function [opts coll x0] = var_amendCollocationSystem(opts, coll, x0, var_seglist)
%Create full collocation system and an initial solution.

% construct collocation system and initial guess over all segments
[opts coll] = var_amendMeshSegments(opts, coll, var_seglist);

% combine segment information into full collocation
% system and an initial solution
[opts coll x0] = var_mergeSegments(opts, coll, x0);
