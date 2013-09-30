switchpath('old')
% Create an initial data structure for the discretized boundary value
% problem.

fdata.dim = 10;
fdata.u_idx = 1:fdata.dim+2;
fdata.p_idx = (fdata.dim+3):(fdata.dim+4);
fdata.A = spdiags([ones(fdata.dim,1) -2*ones(fdata.dim,1) ...
    ones(fdata.dim,1)], [0, 1, 2], fdata.dim, fdata.dim+2);
fdata.B = 1/12 * spdiags([ones(fdata.dim,1) 10*ones(fdata.dim,1) ...
        ones(fdata.dim,1)],[0 1 2], fdata.dim, fdata.dim+2);
fdata.h2 = 1/(fdata.dim+1)^2;

fdata.f = @combustion;

% An initial guess
p0 = [0; 0.19];
u0 = zeros(fdata.dim+2,1);

% Since the file @finitediff_DFDX exists in the folder, provide information
% to enable its execution.

fdata.f_DX = @combustion_DFDX;
fdata.f_DP = @combustion_DFDP;

% Define zero problem and parameter monitor functions.
opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx, {'L', 'M'});

% Add limit point detection.
fdata.dfdx = @finitediff_DFDX;
opts = coco_add_func(opts, 'finitediff_fold1', @finitediff_fold1, fdata, 'regular', 'fold');
opts = coco_add_event(opts, 'LP', 'fold', 0);

% Continue
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 200);
bd = coco(opts, 'run', [], 'L', [0 6]);

lambda   = coco_bd_col(bd, 'L');
mu       = coco_bd_col(bd, 'mu');
midpoint = coco_bd_col(bd, 'midpoint');
idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE')));

figure(1)
clf
hold on
plot3(lambda,midpoint,mu,'r')
hold on
plot3(lambda(idx),midpoint(idx),mu(idx),'rs')
hold off

% Extract solution at limit point.
labs = coco_bd_col(bd, 'LAB');
[tempdata sol] = coco_read_solution('', 'run', labs{idx(1)});

p0 = sol.x(fdata.p_idx);
u0 = sol.x(fdata.u_idx);

% Define zero problem and parameter monitor functions.
opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx, {'L', 'M'});

% Add limit point zero problem using determinant condition.
opts = coco_add_func(opts, 'finitediff_fold1', @finitediff_fold1, fdata, 'active', 'fold');
opts = coco_xchg_pars(opts, 'L', 'fold');

% Continue
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 200);
bdLP1 = coco(opts, 'runLP1', [], {'M' 'fold'}, [0 1]);

lambda   = coco_bd_col(bdLP1, 'lambda');
mu       = coco_bd_col(bdLP1, 'mu');
midpoint = coco_bd_col(bdLP1, 'midpoint');

figure(1)
hold on
plot3(lambda,midpoint,mu,'g')
hold off

% Define zero problem and parameter monitor function.
opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx(2), 'M');

% Compute data structure content for eigenvector condition.
[fdata JJ] = fdata.dfdx([], fdata, sol.x);
[v,d] = eig(full(JJ(1:fdata.dim+2,1:fdata.dim+2)));
[l,k] = min(abs(diag(d)));
sigma0 = v(:,k);
fdata.sigma_idx = (fdata.dim+5):(fdata.dim+4+fdata.dim+2);
fdata.c = sigma0;
fdata_ptr = coco_ptr(fdata);

% Add limit point zero problem and update function using eigenvector condition.
opts = coco_add_func(opts, 'finitediff_fold2', @finitediff_fold2, fdata_ptr, ...
    'zero', 'x0', sigma0, 'xidx', [fdata.u_idx fdata.p_idx fdata.sigma_idx]);
opts = coco_add_slot(opts, 'update', @update1, fdata_ptr, 'covering_update');

% Continue
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 200);
bdLP2 = coco(opts, 'runLP2', [], 'M', [0 1]);

lambda   = coco_bd_col(bdLP2, 'lambda');
mu       = coco_bd_col(bdLP2, 'mu');
midpoint = coco_bd_col(bdLP2, 'midpoint');

figure(1)
hold on
plot3(lambda,midpoint,mu,'b')
hold off

% Define zero problem and parameter monitor function.
opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx(2), 'M');

% Add limit point zero problem using unit eigenvector condition.
opts = coco_add_func(opts, 'finitediff_fold3', @finitediff_fold3, fdata, ...
    'zero', 'x0', sigma0, 'xidx', [fdata.u_idx fdata.p_idx fdata.sigma_idx]);


% Continue
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 200);
bdLP3 = coco(opts, 'runLP3', [], 'M', [0 1]);

lambda   = coco_bd_col(bdLP3, 'lambda');
mu       = coco_bd_col(bdLP3, 'mu');
midpoint = coco_bd_col(bdLP3, 'midpoint');

figure(1)
hold on
plot3(lambda,midpoint,mu,'k')
hold off

% Compute data structure content for minimally augmented condition.
[fdata JJ] = fdata.dfdx([], fdata, sol.x);
[v,d] = eig(full(JJ(1:fdata.dim+2,1:fdata.dim+2)));
[l,k] = min(abs(diag(d)));
fdata.c = v(:,k);
[v,d] = eig(full(JJ(1:fdata.dim+2,1:fdata.dim+2)'));
[l,k] = min(abs(diag(d)));
fdata.b = v(:,k);

% Compute data structure content for branchpoint detection.
fdata.dfdp = @finitediff_DFDP;
fdata_ptr = coco_ptr(fdata);

% Define zero problem and parameter monitor function
opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx(2), 'M');

% Add limit point zero problem and update function using minimally augmented condition
opts = coco_add_func(opts, 'finitediff_fold4', @finitediff_fold4, fdata_ptr, ...
    'zero');
opts = coco_add_slot(opts, 'update', @update2, fdata_ptr, 'covering_update');

% Add branchpoint detection
opts = coco_add_func(opts, 'branchpoint', @branchpoint, fdata_ptr, 'singular', {'bp1', 'bp2'});
opts = coco_add_event(opts, 'BP1', 'bp1', 0);
opts = coco_add_event(opts, 'BP2', 'bp2', 0);

% Continue
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 200);
bdLP4 = coco(opts, 'runLP4', [], {'M' 'bp1' 'bp2'}, [0 1]);

lambda   = coco_bd_col(bdLP4, 'lambda');
mu       = coco_bd_col(bdLP4, 'mu');
midpoint = coco_bd_col(bdLP4, 'midpoint');

figure(1)
hold on
plot3(lambda,midpoint,mu,'m')
hold off
