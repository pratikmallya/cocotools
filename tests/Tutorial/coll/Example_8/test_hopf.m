% Test demo for studying branch-switching at Hopf point of canard example.
% We observe an extreme sensitivity on NTST. This seems to be due to the
% strong dependence on the period (the tangent component for T is very
% large) together with the approximation error in the period, which is
% strange, because the approximation error is extremely small. This must
% have something to do with the geometry, but I don't understand how.
%
% This is an example where branch-switching in the amplitude monitor
% function we defined in earlier versions of the text will be more robust
% (we switch to an orbit with defined amplitude instead of projecting with
% the vertical tangent, which is quite non-vertical wrt. period here).
%
% try different h = 0.1 0.01 0.001 0.0001
% and NTST = 5 50 500 1000

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

% initial correction, note dependency on NTST

addpath('../Pass_3', '../../po');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'PtMX', 0);
prob = coco_set(prob, 'coll', 'NTST', 10);
prob = coco_set(prob, 'coll', 'TOL', 1.0e-4);
prob = po_isol2orb(prob, '', @canard, t0', p1', {'a' 'eps'}, [a;eps]);
coco(prob, 'run1', [], 1, {'a' 'po.period' 'po.seg.coll.err'}, [-1 -0.9]);

%!tkn3

clf
plot(p1(1,:),p1(2,:))
hold on
  sol = po_read_solution('', 'run1', 1);
  plot(sol.x(:,1), sol.x(:,2), 'b.-')
hold off

%!
rmpath('../Pass_3', '../../po');
