function prob = riess_start_1(prob, run, lab)

[prob data sol] = povar_sol2orb(prob, '', run, lab);

fdata = coco_get_func_data(prob, data.coll_id, 'data');
eps0  = [0.1; 0.1];
p0    = sol.x(fdata.p_idx);

s  = p0(1);
r  = p0(2);
t0 = 0;
x0 = eps0(1)*[(1-s+sqrt((1-s)^2+4*r*s))/2/r; 1; 0]';
coll_args = {fdata.fhan, fdata.dfdxhan, fdata.dfdphan, t0, x0, p0};
prob = coll_isol2seg(prob, 'col1', coll_args{:});

M      = reshape(sol.x(data.ubp_idx), data.u_shp);
M1     = M(data.M1_idx,:);
[v, d] = eig(M1);
ind    = find(abs(diag(d))<1);
vec0   = -v(:,ind);
lam0   = d(ind,ind);

t0 = 0;
x0 = sol.x(fdata.xbp_idx(end-data.dim+1:end))'+eps0(2)*vec0';
coll_args = {fdata.fhan, fdata.dfdxhan, fdata.dfdphan, t0, x0, p0};
prob = coll_isol2seg(prob, 'col2', coll_args{:});

data.nrm = [0, -1, 1]/sqrt(2);
data.pt0 = [20; 20; 30];

prob = riess_close_het_1(prob, data, vec0, lam0, eps0);

end