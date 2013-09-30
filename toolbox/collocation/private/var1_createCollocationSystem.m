function [opts coll M0] = var1_createCollocationSystem(opts, coll, x0, p0)
%Create full collocation system and an initial solution.

% construct collocation system and initial guess over all segments
[opts coll]    = var1_createMeshSegments(opts, coll);

% combine segment information into full collocation
% system and an initial solution
[opts coll M0] = var1_mergeSegments(opts, coll);

% construct list of right-hand sides and corresponding segments
[opts coll]    = var1_computeDFODE(opts, coll, x0, p0);
