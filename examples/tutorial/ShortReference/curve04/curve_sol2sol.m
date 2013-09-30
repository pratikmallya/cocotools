function [opts argnum] = curve_sol2sol(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at a saved solution
% from a previous run. Called by coco as follows:
%   coco(opts, RUN, 'curve','sol','sol', RRUN, RLAB, PAR, PAR_INT)

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% We pass the restored data to the constructor. In principle, this
% function could handle more arguments for user-friendliness.
opts   = curve_create(opts, f, x0, p0);

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 3;
end
