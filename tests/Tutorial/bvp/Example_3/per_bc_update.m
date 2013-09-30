function data = per_bc_update(data, T, x0, x1, p)

n = numel(x0);
q = numel(p);

data.x0 = x0;
data.f0 = data.fhan(x0,p)';
data.J  = [sparse(n,1), speye(n,n), -speye(n,n), sparse(n,q);
           sparse(1,1), data.f0,    sparse(1,n), sparse(1,q)];

end