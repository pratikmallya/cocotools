function segs = create_isol(K, NTST, NCOL, eps, n)

if nargin<4
  eps = 0.5;
end
if nargin<5
  n = 5;
end

T   = 2*pi/K;
x0  = [0; 1];

if eps>=0
  f = @(t,x) pneta(x, eps);
else
  f = @(t,x) -pneta(x, eps);
end

[t1 x1] = ode45(f, [0 n*T], x0); %#ok<ASGLU>
x0      = x1(end,:)';

f = @(t,x) pneta(x, eps);
for i=1:K
	[t1 x1] = ode45(f, [0 T], x0);

	segs(i).fname = []; %#ok<AGROW>
	segs(i).t0    = t1; %#ok<AGROW>
	segs(i).x0    = x1'; %#ok<AGROW>
	segs(i).NTST  = NTST; %#ok<AGROW>
	segs(i).NCOL  = NCOL; %#ok<AGROW>
	
	x0 = x1(end,:)';
end
