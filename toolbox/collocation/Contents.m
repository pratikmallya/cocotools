%MPBVP  Multi-point boundary value problem toolbox.
%
%Entry point for continuation:
%   mpbvp_isol2sol                 - Construct boundary value problem and start continuation.
%
%Construct and manipulate BVPs:
%   mpbvp_createInitialSegList     - Convert initial data into a list of segments.
%   mpbvp_createCollocationSystem  - Create full collocation system and an initial solution.
%
%Low-level interface:
%   mpbvp_createMeshSegments       - Create a list of collocation systems over all segments.
%   mpbvp_createRHSList            - Create a list of right-hand sides over all segments.
%   mpbvp_mergeSegments            - Create the full collocation system by merging all segments.
%   mpbvp_createBoundaryConditions - Create and initialise boundary conditions.
%
