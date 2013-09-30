function coll_opts()
%List of options used by the toolbox MPBVP.
%
%Class func:
%   F        [ @coll_F        ]
%   DFDX     [ @coll_DFDX     ]
%   DFDP     [ @coll_DFDP     ]
%   linsolve [ @coll_linsolve ]
% 
%Class coll:
%   NTST      : number of collocation intervals
%   NCOL      : number of collocation points
%   bpdist    : method for distributing interpolation points
%   dim       : dimension of phase-space
%   segs      : list of collocation systems
%   seglist   : list of solution segments
%   rhss      : list of vector fields
%   fullsize  : (column) dimension of full collocation system
%   W         : full point map
%   Wp        : full derivatives map
%   Phi       : linear map of continuity condition
%   ka        : rescaling factors
%   kaxidx    : indices for expanding ka to size xshape
%   kadxidx   : indices for expanding ka to size dxshape
%   dxrows    : row indices for Jacobians of vector fields
%   dxcols    : column indices for Jacobians of vector fields
%   xshape    : shape of array of collocation points
%   dxshape   : shape of array of Jacobians of vector fields
%   x0idx     : indices of initial points of segments
%   x1idx     : indices of end points of segments
%   x0shape   : shape of array of all initial points
%   x1shape   : shape of array of all end points
%   tintidx   : indices of time intervals T
%   tintxidx  : indices for expanding T to size xshape
%   tintdxidx : indices for expanding T to size dxshape
%   tintshape : shape of array of all time intervals
%   bcond     : name of function defining the boundary conditions
% 
%Class bcond:
%   bcname : name of boundary condition
%   F      : boundary condition in functional form
%   DFDX   : linearisation of boundary condition
%   DFDP   : parameter derivatives of boundary condition
%   init   : function for initialising boundary condition
%   update : function for updating boundary condition during continuation
%
%   See also: coco_opts
%

help coll_opts
