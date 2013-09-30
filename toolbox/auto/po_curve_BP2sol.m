function [opts argnum] = po_curve_BP2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at a branch point.

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

% compute vector 't' normal to 'data.t' such that the plane spanned by 't'
% and 'data.t' contains both branches approximately
[X D]   = eig(data.J);
[v idx] = min(abs(diag(D))); %#ok<ASGLU>
t       = X(:,idx);
t       = t/norm(t);
tx      = t(data.x_idx);
tp      = zeros(size(p0));
tp(data.acp_idx) = t(end-1);
tT      = t(end);

% make small step in direction of [tx;tp]
hh = coco_get(opts, 'cont.h0');
if isstruct(hh)
  hh = 0.01;
else
  hh = 0.5*hh;
end
x0 = x0 + hh*tx;
p0 = p0 + hh*tp;
T0 = T0 + hh*tT;

% call toolbox constructor
opts = po_curve_create(opts, f, fx, fp, g, gx, gp, h, hx, hp, ...
  x0, p0, T0, tx, tp, tT);

end
