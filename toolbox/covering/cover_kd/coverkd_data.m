classdef coverkd_data < handle
  properties
    mode=0; t; s; k, u0; h; hred=0; fixpar_idx; fixpar_val;
    % bug: F and DFDX are required by nwtn and should be defined elsewhere
    F; DFDX; linsolve;
  end
end
