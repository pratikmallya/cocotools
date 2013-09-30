function [opts argnum] = fp_curve_NS2NS(opts, prefix, rrun, rlab, varargin) %#ok<INUSL>
% Parser of toolbox curve, starting at a saved solution point.

% compute number of processed arguments, varargin is ignored here
argnum = 3;

% switch off saddle-node test function
% opts = coco_set(opts, 'curve', 'SN', false);

% Restore data associated with a specific run and solution label from disc.
% 'data' will contain the toolbox data structure, and 'sol' contains a
% structure with the solution vector (and more). We only access the
% solution vector 'sol.x'.
[data sol] = coco_read_solution('curve_save', rrun, rlab);
f  = data.f;
fx = data.fx;
fp = data.fp;
k  = data.k;
x0 = sol.x(data.x_idx);
p0 = sol.x(data.p_idx);

% call toolbox constructor for zero problem
opts = fp_curve_create(opts, f, fx, fp, x0, p0, k, [], []);

% compute eigenvalue and right eigenvectors for complex pair on unit circle
[X D]   = eig(data.J);
[v idx] = min(abs(abs(diag(D))-1)); %#ok<ASGLU>
om0real = real(D(idx,idx));
om0imag = imag(D(idx,idx));
v0      = real(X(:,idx));
w0      = imag(X(:,idx));

% call toolbox constructor for fold condition
data = coco_get_func_data(opts, 'curve', 'data');
opts = fp_curve_create_NS(opts, data, v0, w0, om0real, om0imag);

end
