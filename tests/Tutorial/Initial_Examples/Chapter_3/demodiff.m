echo on
%!tkn1
N = 40;
data.dep_idx = (1:2*N+4)';
data.par_idx = [2*N+5; 2*N+6];
data.f_idx   = (1:2:2*N+3)';
data.g_idx   = (2:2:2*N+4)';
oneN   = ones(2*N,1);
zeroN  = zeros(2*N,1);
data.A = spdiags([oneN zeroN -2*oneN zeroN oneN], ...
  [0 1 2 3 4], 2*N, 2*N+4);
data.B = 1/(12*(N+1)^2)*spdiags([oneN zeroN 10*oneN zeroN oneN], ...
  [0 1 2 3 4], 2*N, 2*N+4);
x0   = ones(1,N+2);
y0   = ones(1,N+2);
p0   = [1; 1];
dep0 = [x0; y0];
u0   = [dep0(:); p0];
prob = coco_prob();
prob = coco_add_func(prob, 'finitediff', @finitediff, data, ...
  'zero', 'u0', u0);
%!tkn2
prob = coco_add_pars(prob, 'pars', [1:2 2*N+3:2*N+6]', ...
  {'f0' 'g0' 'f1' 'g1' 'p1' 'p2'});
%!tkn3
prob = coco_add_slot(prob, 'finitediff', @coco_save_data, data, 'save_full');
%!tkn4
coco(prob, 'brusselator', [], 1, 'g0', [0 10]);
%!tkn5
coco_get_func_data(prob, 'finitediff', 'data')
%!tkn6
echo off