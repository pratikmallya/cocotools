function J = po_jacobian(data, u, varargin)
p        = u(data.p_idx);
[M N x1] = po_var_sol(data, u, varargin{:});

gx  = data.gx(x1,p, data.x0,data.f0);
gp  = data.gp(x1,p, data.x0,data.f0);
hx  = data.hx(x1,p, data.x0,data.f0);
hp  = data.hp(x1,p, data.x0,data.f0);
f1  = data.f(x1,p);

if nargin>=3
  gp = gp(:,varargin{1});
  hp = hp(:,varargin{1});
end

Jgx = gx*M - eye(numel(x1));
Jgp = gx*N + gp;
JgT = gx*f1;

Jhx = hx*M;
Jhp = hx*N + hp;
JhT = hx*f1;

J = [
  Jgx  Jgp  JgT
  Jhx  Jhp  JhT
  ];
end
