function [opts coll x0] = var2_amendCollocationSystem(opts, coll, x0, var_seglist)
%Create full collocation system and an initial solution.

% construct collocation system and initial guess over all segments
[opts coll] = var2_amendMeshSegments(opts, coll, var_seglist);

% combine segment information into full collocation
% system and an initial solution
[opts coll x0] = var2_mergeSegments(opts, coll, x0);
