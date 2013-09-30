function [opts argnum] = ep_curve_sol2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at a saved solution point.

% compute number of processed arguments, varargin is ignored here
argnum = 3;

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
fx = data.fx;
fp = data.fp;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% call toolbox constructor
opts = ep_curve_create(opts, f, fx, fp, x0, p0, [], []);

end
