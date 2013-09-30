function [opts argnum] = po_curve_sol2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
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

g  = data.g;
gx = data.gx;
gp = data.gp;

h  = data.h;
hx = data.hx;
hp = data.hp;

x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);
T0 = sol.x(data.T_idx);

% call toolbox constructor
opts = po_curve_create(opts, f, fx, fp, g, gx, gp, h, hx, hp, ...
  x0, p0, T0, [], [], []);

end
