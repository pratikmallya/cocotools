function segs = create_isol(K, NTST, NCOL)

eps = 0.5;
f   = @(t,x) pneta(x, eps);
T   = 2*pi/K;
x0  = [0; 0.79];

for i=1:K
	[t1 x1] = ode45(f, [0 T], x0);

	segs(i).fname = []; %#ok<AGROW>
	segs(i).t0    = t1; %#ok<AGROW>
	segs(i).x0    = x1'; %#ok<AGROW>
	segs(i).NTST  = NTST; %#ok<AGROW>
	segs(i).NCOL  = NCOL; %#ok<AGROW>
	
	x0 = x1(end,:)';
end
