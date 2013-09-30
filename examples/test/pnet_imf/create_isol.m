function segs = create_isol(x0, p0, p, q, K, NTST, NCOL)

f   = @(t,x) pnet(x, p0);
T   = q*pi/(p*K);

[t1 x1] = ode45(f, [0 q*5*pi], x0); %#ok<ASGLU>
x0      = x1(end,:)';
x0(3)   = 0;

for i=1:K
	[t1 x1] = ode45(f, linspace(0,T,NTST*NCOL), x0);

	segs(i).fname = []; %#ok<AGROW>
	segs(i).t0    = t1; %#ok<AGROW>
	segs(i).x0    = x1'; %#ok<AGROW>
	segs(i).NTST  = NTST; %#ok<AGROW>
	segs(i).NCOL  = NCOL; %#ok<AGROW>
	
	x0 = x1(end,:)';
end
