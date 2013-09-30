eps0 = 6;
t0 = linspace(0,2*pi,100)';
x0 = [ sin(t0) cos(t0) ];

prob = coco_prob();
prob = coco_set(prob, 'fft', 'TOL', 1e-3);

prob2 = coco_set(prob, 'fft', 'NMAX', 100, 'NMOD', 30);
prob2 = spectral_isol2fft(prob2, '', @(x,p,model) pneta(x,p), ...
  t0, x0, 'eps', eps0);
bd = coco(prob2, '1', [], 0, {'eps' 'fft.err' 'fft.NMOD'});

sol = spectral_read_solution('', '1', 1);
norm(sol.c(:))

clf

subplot(2,1,1)
plot(sqrt(sum(sol.c.^2,1)))

subplot(2,1,2)
plot(sol.x(:,1), sol.x(:,2))
