function prob = varcoll_close_seg(prob, tbid, data, u0)

uidx = coco_get_func_data(prob, tbid, 'uidx');
fid  = coco_get_id(tbid, 'var');
data.tbid = fid;
data = coco_func_data(data);
prob = coco_add_slot(prob, fid, @var_update, data, 'update');
prob = coco_add_func(prob, fid, @var_F, @var_DFDU, data, 'zero', ...
  'uidx', uidx, 'u0', u0);
prob = coco_add_slot(prob, fid, @coco_save_data, data, 'save_full');

uidx = coco_get_func_data(prob, fid, 'uidx');
fid  = coco_get_id(tbid, 'eigs');
eigs = cell(data.dim,1);
for i=1:data.dim
  eigs{i} = sprintf('l%d',i);
end
prob = coco_add_func(prob, fid, @var_eigs, data, 'regular', ...
  eigs, 'uidx', uidx(data.ubp_idx), 'fdim', data.dim);

end

function [data y] = var_F(prob, data, u)

NTST = data.coll.NTST;

T   = u(data.T_idx); %1 x 1
Mbp = reshape(u(data.ubp_idx), data.u_shp); % nN(m+1) x n

xx  = reshape(data.W*u(data.xbp_idx), data.x_shp); %n x Nm
pp  = repmat(u(data.p_idx), data.p_rep); %p x Nm

dfvecdx = data.dfdxhan(xx, pp, data.mode); % n x n x Nm
dfvecdx = sparse(data.dxrows, data.dxcols, dfvecdx(:)); % nNm x nNm
dfodedx = (0.5*T/NTST)*dfvecdx*data.W-data.Wp; % nNm x nN(m+1)

dfode  = dfodedx*Mbp; % nNm x n;
dfcont = data.Q*Mbp; % n(N-1) x n
dbcond = data.B*Mbp-3*data.Id; % n x n
y = [dfode(:); dfcont(:); dbcond(:)]; % n^2*Nm+n^2(N-1)+n^2 x 1

end

function [data J] = var_DFDU(prob, data, u)

NTST = data.coll.NTST;

T   = u(data.T_idx); %1 x 1
Mbp = reshape(u(data.ubp_idx), data.u_shp); % nN(m+1) x n

xx  = reshape(data.W*u(data.xbp_idx), data.x_shp); %n x Nm
pp  = repmat(u(data.p_idx), data.p_rep); %p x Nm

dfvecdx  = data.dfdxhan(xx, pp, data.mode); % n x n x Nm
dfvecdx  = sparse(data.dxrows, data.dxcols, dfvecdx(:)); % nNm x nNm

dfvecdxdx = data.dfdxdxhan(xx, pp, data.mode); % n x n x n x Nm
dfvecdxdx = sparse(data.dxdxrows1, data.dxdxcols1, dfvecdxdx(:)); % n^2*Nm x nNm
dfodedxdx = dfvecdxdx*data.W; % n^2*Nm x nN(m+1)
dfodedxdx = sparse(data.dxdxrows2, data.dxdxcols2, dfodedxdx(:))*data.W*Mbp; % n^2*N^2*m(m+1) x n
dfodedxdx = (0.5*T/NTST)*sparse(data.dxdxrows3, data.dxdxcols3, dfodedxdx(:)); % n^2*Nm x nN(m+1)

dfodedxdT = (0.5/NTST)*dfvecdx*data.W*Mbp;

dfvecdxdp = data.dfdxdphan(xx, pp, data.mode); % n x n x Nm x p
dfodedxdp = sparse(data.dxdprows1, data.dxdpcols1, dfvecdxdp(:))*data.W*Mbp; % nNmp x n
dfodedxdp = (0.5*T/NTST)*sparse(data.dxdprows2, data.dxdpcols2, dfodedxdp(:)); % n^2*Nm x p

dfodedxdu = kron(data.Id, (0.5*T/NTST)*dfvecdx*data.W-data.Wp);

J = [dfodedxdx, dfodedxdT(:), dfodedxdp, dfodedxdu; data.jac];

% [data Jt] = coco_ezDFDX('f(o,d,x)', prob, data, @var_F, u);

end

function data = var_update(prob, data, cseg, varargin)

uidx = coco_get_func_data(prob, data.tbid, 'uidx');
u    = cseg.base_chart.x(uidx);

x = u(data.xbp_idx);
T = u(data.T_idx);
p = u(data.p_idx);

NTST = data.coll.NTST;
dim  = data.dim;
deye = data.Id;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);

dfode = data.dfdxhan(xx, pp, data.mode);
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);
rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];

M0 = reshape(u(data.ubp_idx), data.u_shp);
J0 = sparse(rows, cols, [vals(:); data.Qvals(:)]);
J  = [data.B1+M0'*data.B2; J0];
M  = J\[3*deye; sparse(data.xbp_idx(end)-dim, dim)];
while norm(full(M-M0))>data.coll.TOL
  M0 = M;
  J  = [data.B1+M0'*data.B2; J0];
  M  = J\[3*deye; sparse(data.xbp_idx(end)-dim, dim)];
end
data.M0  = M;
data.B   = data.B1+data.M0'*data.B2;
data.jac = [sparse(data.dim^2*data.coll.NTST, ...
  data.dim*data.coll.NTST*(data.coll.NCOL+1)+1+data.pdim) ...
  [kron(data.Id, data.Q); kron(data.Id, data.B)]];

end %!end_var_update

function [data y] = var_eigs(prob, data, u)

Mbp = reshape(u, data.u_shp);
M0  = full(Mbp(1:data.dim,:));
M1  = full(Mbp(end-data.dim+1:end,:));
y   = real(eig(M1,M0));

end