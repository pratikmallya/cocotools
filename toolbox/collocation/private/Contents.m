%Pivate functions of toolbox MPBVP.
%
%Collocation system:
%   coll_F                     - Evaluate collocation system COLL_F at (X,P).
%   coll_DFDX                  - Compute linearisation COLL_DFDX of collocation system at (X,P).
%   coll_DFDP                  - Compute parameter derivatives DCOLL_F/DP(PARS) at (X,P).
%
%Linear equation solver:
%   coll_linsolve              - Default solver for linearised equations.
%
%Default boundary conditions.
%
%* Periodic solutions:
%   default_bc_periodic_F      - Evaluate periodic boundary and integral phase condition.
%   default_bc_periodic_DFDX   - Compute linearisation of periodic boundary condition.
%   default_bc_periodic_DFDP   - Compute parameter derivative of periodic boundary condition.
%   default_bc_periodic_init   - Initialise matrices used in periodic boundary condition.
%   default_bc_periodic_update - Update previous-point information for periodic boundary condition.
%
%* Hybrid systems:
%   default_bc_hybrid_F        - Evaluate jump conditions of hybrid system.
%   default_bc_hybrid_DFDX     - Compute linearisation of jump conditions.
%   default_bc_hybrid_DFDP     - Compute parameter derivatives of jump conditions.
%   default_bc_hybrid_init     - Does nothing.
%   default_bc_hybrid_update   - Does nothing.
%
%Orthogonal polynomials:
%   gaussnodes                 - Compute location of N Gauss nodes in [-1,1].
%   lagrange_bpoints           - Compute base points for Lagrange interpolation in [-1,1].
%   lagrange_pmap              - Linear mapping from interpolation to collocation points.
%   lagrange_dmap              - Linear mapping from interpolation to derivative at collocation points.
%
%Callback functions:
%   mpbvp_save_full            - Add plotting data to class SOL.
%   mpbvp_save_reduced         - Does nothing.
%   mpbvp_print_headline       - Print headline for additional output period.
%   mpbvp_print_data           - Print sum over all time differences (the period).
%   mpbvp_update               - Forwards COCO's update message to boundary conditions.
%
%Miscellaneous:
%   mpbvp_monodromy            - Primitive (unstable) algorithm for computing Floquet multipliers.
%   var_F                      - Linearisation of 'variational equation BVP' for multipliers.
