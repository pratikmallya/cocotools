% Comparison of all adaptation methods using the canard explosion as a test
% example. We start at the Hopf point and (try to) compute the complete
% falily of canard orbits.

% Remember, the aim of this part is to demonstrate how to couple adaptation
% with continuation. The methods themselves could be improved
% substantially. For example, the error as a function of the parameter is
% quite eratic, some research could help smoothen this significantly. Use
%
%   plot(coco_bd_col(bd,'PT'), coco_bd_col(bd,'po.seg.coll.err'))
%
% after each run to see this.

% echo on

% construct initial solution close to Hopf point
%!tkn1
a   = -1;
eps = 0.01;
h   = 0.001;

x0  = [ a^3/3-a ; a ];

om  = sqrt(eps);

xi  = [ 1 ; -om/eps*1i ];
xi  = xi/norm(xi);

p0  = @(t) x0*ones(size(t)) + h*real(xi)*sin(om*t) + h*imag(xi)*cos(om*t);

t0  = linspace(0,2*pi/om, 100);
p1  = p0(t0);

%!tkn2

%% Run with spectral method

addpath('../../spectral');

prob = coco_prob();
prob = coco_set(prob, 'lsol', 'cond', true);
prob = coco_set(prob, 'cont', 'PtMX', 1000, 'NPR', 100, 'bi_direct', false);
prob = coco_set(prob, 'cont', 'h_max', 2);
prob = coco_set(prob, 'dft', 'TOL', 1e-2);
prob = coco_set(prob, 'dft', 'NMAX', 100, 'NMIN', 5, 'NMOD', 5);
prob = dft_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
prob = coco_add_event(prob, 'UZ', 'dft.period', [100:100:400 460]);
prob = coco_add_func_after(prob, 'mfunc', @lsol_cond);
coco(prob, '1', [], 1, ...
  {'dft.period' 'a' 'dft.NMOD' 'dft.err' 'lsol.cond'}, {[0 1000] [-1 -0.9]});

%!tkn3

clf
plot(p1(1,:),p1(2,:),'g.-')
hold on
bd   = coco_bd_read('1');
labs = coco_bd_labs(bd, 'UZ');
for lab = labs
  sol = dft_read_solution('', '1', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
end
hold off

%!
coco_clear_cache('reset');
rmpath('../../spectral');

%% Run with equidistributed mesh

addpath('../Pass_3', '../../po');

prob = coco_prob();
prob = coco_set(prob, 'lsol', 'cond', true);
prob = coco_set(prob, 'cont', 'PtMX', 1000, 'NPR', 100, 'bi_direct', false);
prob = coco_set(prob, 'cont', 'h_max', 2);
prob = coco_set(prob, 'coll', 'NTST', 100, 'TOL', 1.0e-2);
prob = po_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
prob = coco_add_event(prob, 'UZ', 'po.period', [100:100:400 460]);
prob = coco_add_func_after(prob, 'mfunc', @lsol_cond);
coco(prob, '2', [], 1, ...
  {'po.period' 'a' 'po.seg.coll.NTST' 'po.seg.coll.err' 'lsol.cond'}, ...
  {[0 1000] [-1 -0.9]});

%!tkn3

clf
plot(p1(1,:),p1(2,:),'g.-')
hold on
bd   = coco_bd_read('2');
labs = coco_bd_labs(bd, 'UZ');
for lab = labs
  sol = po_read_solution('', '2', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
end
hold off

%!
coco_clear_cache('reset');
rmpath('../Pass_3', '../../po');

%% Run with moving mesh fixed order

addpath('../Pass_4', '../../po/adapt');

prob = coco_prob();
prob = coco_set(prob, 'lsol', 'cond', true);
prob = coco_set(prob, 'cont', 'PtMX', 1000, 'NPR', 100, 'bi_direct', false);
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'h_max', 2);
prob = coco_set(prob, 'coll', 'NTST', 70);
prob = po_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
prob = coco_add_event(prob, 'UZ', 'po.period', [100:100:400 460]);
prob = coco_add_func_after(prob, 'mfunc', @lsol_cond);
coco(prob, '3', [], 1, ...
  {'po.period' 'a' 'po.seg.coll.NTST' 'po.seg.coll.err' 'lsol.cond'}, ...
  {[0 1000] [-1 -0.9]});

%!tkn3

clf
plot(p1(1,:),p1(2,:),'g.-')
hold on
bd   = coco_bd_read('3');
labs = coco_bd_labs(bd, 'UZ');
for lab = labs
  sol = po_read_solution('', '3', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
end
hold off

%!
coco_clear_cache('reset');
rmpath('../Pass_4', '../../po/adapt');

%% Run with moving mesh adaptive order

addpath('../Pass_5', '../../po/adapt');

prob = coco_prob();
prob = coco_set(prob, 'lsol', 'cond', true);
prob = coco_set(prob, 'cont', 'PtMX', 1000, 'NPR', 100, 'bi_direct', false);
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'h_max', 2);
prob = po_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
prob = coco_add_event(prob, 'UZ', 'po.period', [100:100:400 460]);
prob = coco_add_func_after(prob, 'mfunc', @lsol_cond);
coco(prob, '4', [], 1, ...
  {'po.period' 'a' 'po.seg.coll.NTST' 'po.seg.coll.err' 'lsol.cond'}, ...
  {[0 1000] [-1 -0.9]});

%!tkn3

clf
plot(p1(1,:),p1(2,:),'g.-')
hold on
bd   = coco_bd_read('4');
labs = coco_bd_labs(bd, 'UZ');
for lab = labs
  sol = po_read_solution('', '4', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
end
hold off

%!
coco_clear_cache('reset');
rmpath('../Pass_5', '../../po/adapt');

%% Run with co-moving mesh

addpath('../Pass_6', '../../po/adapt');

prob = coco_prob();
prob = coco_set(prob, 'lsol', 'cond', true);
prob = coco_set(prob, 'cont', 'PtMX', 1000, 'NPR', 100, 'bi_direct', false);
prob = coco_set(prob, 'cont', 'h_max', 2);
prob = coco_set(prob, 'coll', 'NTST', 100, 'TOL', 1.0e-2, 'hfac', 5);
prob = po_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
prob = coco_add_event(prob, 'UZ', 'po.period', [100:100:400 460]);
prob = coco_add_func_after(prob, 'mfunc', @lsol_cond);
coco(prob, '5', [], 1, ...
  {'po.period' 'a' 'po.seg.coll.NTST' 'po.seg.coll.err' 'lsol.cond'}, ...
  {[0 1000] [-1 -0.9]});

%!tkn3

clf
hold on
plot(p1(1,:),p1(2,:),'g.-')
bd   = coco_bd_read('5');
labs = coco_bd_labs(bd, 'UZ');
for lab = labs
  sol = po_read_solution('', '5', lab);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
end
hold off

%!
coco_clear_cache('reset');
rmpath('../Pass_6', '../../po/adapt');

echo off
