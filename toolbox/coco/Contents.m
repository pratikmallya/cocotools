
% Continuation Core Toolbox
% Copyright (C) 2007 by Frank Schilder, Harry Dankowicz
%
%   coco                   - Top-level entry point to continuation toolboxes.
%


%
%   coco_nwtn              - Entry point to Newton's method.
%   coco_nwtn_step         - Execute one Newton step.
%
%   coco_set               - Create/alter COCO options structure.
%   coco_opts              - List of options used by the continuation core.
%
%   coco_num_DFDP          - Numerical differentiation wrt. parameter, non-vectorised.
%   coco_num_DFDPv         - Numerical differentiation wrt. parameter, vectorised.
%   coco_num_DFDX          - Numerical differentiation wrt. state, non-vectorised.
%   coco_num_DFDXv         - Numerical differentiation wrt. state, vectorised.
%
%   coco_set_func          - Define zero problem for continuation.
%   coco_add_func          - Add monitor function to system of equations.
%   coco_add_event         - Add event to parameter.
%   coco_xchg_pars         - Exchange inactive, active and internal parameters.
%   coco_set_dim           - Set dim. of manifold and define prim. cont. parameters.
%
%   coco_set_xinfo         - Set permutation vectors.
%   coco_get_def_par_names - Create list of default parameter names.
%   coco_idx2par           - Return parameter names at given indices.
%   coco_par2idx           - Return indices of parameters.
%
% References:
