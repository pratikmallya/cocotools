%!dft_construct_orb
function prob = dft_construct_orb(prob, tbid, data, sol)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_func(prob, tbid, @dft_F, @dft_DFDU, data, ...
  'zero', 'u0', sol.u0);
uidx = coco_get_func_data(prob, tbid, 'uidx');
fid  = coco_get_id(tbid, 'period');
prob = coco_add_pars(prob, fid, uidx(data.T_idx), fid, 'active');
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, uidx(data.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');
prob = coco_add_slot(prob, tbid, @dft_update, data, 'update');

efid = coco_get_id(tbid, {'err' 'err_TF' 'NMOD'});
prob = coco_add_func(prob, efid{1}, @dft_error, data, ...
  'regular', efid, 'uidx', uidx);
prob = coco_add_event(prob, 'MXCL', 'MX', efid{2}, '>', 1);

end %!end_dft_construct_orb
%!dft_F
function [data y] = dft_F(prob, data, u)

xf = u(data.xf_idx);
xd = u(data.xd_idx);
T  = u(data.T_idx);
p  = u(data.p_idx);

dim  = data.dim;

pp  = repmat(p, data.p_rep);
xp = reshape(data.FinvsW*xf, data.x_shp);
f  = data.fhan(xp, pp);
f  = T*data.Fs*f(:)-data.Wp*xf;
f  = [real(f(1:dim)); real(f(dim+1:end)); imag(f(dim+1:end))];
y  = [f; xd; data.phs*xf];

end %!end_dft_F
%!dft_DFDU
function [data J] = dft_DFDU(prob, data, u)

xf = u(data.xf_idx);
T  = u(data.T_idx);
p  = u(data.p_idx);

dim  = data.dim;
pdim = data.pdim;
mdim = data.mdim;
ddim = data.ddim;

pp  = repmat(p, data.p_rep);
xp = reshape(data.FinvsW*xf, data.x_shp);
if isempty(data.dfdxhan)
  df = coco_ezDFDX('f(x,p)v', data.fhan, xp, pp);
else
  df = data.dfdxhan(xp, pp);
end
df = sparse(data.dxrows, data.dxcols, df(:));
df = T*data.Fs*df*data.FinvsW - data.Wp;
df = [real(df(1:dim,:)); real(df(dim+1:end,:)); imag(df(dim+1:end,:))];

f = data.fhan(xp, pp);
f = data.Fs*f(:);
f = [real(f(1:dim)); real(f(dim+1:end)); imag(f(dim+1:end))];

J1 = [df, sparse(mdim, ddim), f; data.jac];

if isempty(data.dfdphan)
  df = coco_ezDFDP('f(x,p)v', data.fhan, xp, pp);
else
  df = data.dfdphan(xp, pp);
end
df = sparse(data.dprows, data.dpcols, df(:));
df = T*data.Fs*df;
df = [real(df(1:dim,:)); real(df(dim+1:end,:)); imag(df(dim+1:end,:))];

if pdim>0
  dfcont = sparse(ddim+1, pdim);
else
  dfcont = [];
end

J2 = [df; dfcont];

J = sparse([J1 J2]);

end %!end_dft_DFDU
%!dft_update
function data = dft_update(prob, data, cseg, varargin)

uidx = coco_get_func_data(prob, data.tbid, 'uidx');
u    = cseg.src_chart.x(uidx);
xf   = u(data.xf_idx);
p    = u(data.p_idx);

pp   = repmat(p, data.p_rep);
xp   = reshape(data.FinvsW*xf, data.x_shp);
err  = data.fhan(xp, pp)*data.F;
err  = real(err.*conj(err));
err  = sqrt(sum(err(:)));

dft  = data.dft;
NMOD = dft.NMOD;
NMAX = dft.NMAX;
NMIN = dft.NMIN;
dim  = data.dim;
sol.x0 = reshape(xf, [dim 2*NMOD+1]);
NMODi = min(ceil(NMOD*1.1+1),   NMAX);
NMODd = max(ceil(NMOD/1.025-1), NMIN);
if err>dft.TOLINC && NMOD~=NMODi
  data.dft.NMOD = NMODi;
  sol.x0 = [sol.x0 zeros(dim, 2*(NMODi-NMOD))];
  data = dft_init_modes(data, sol);
elseif err<dft.TOLDEC && NMOD~=NMODd
  data.dft.NMOD = NMODd;
  sol.x0 = sol.x0(:,1:2*NMODd+1);
  data = dft_init_modes(data, sol);
end

end %!end_dft_update
%!dft_error
function [data y] = dft_error(prob, data, u)

xf   = u(data.xf_idx);
p    = u(data.p_idx);

pp   = repmat(p, data.p_rep);
xp   = reshape(data.FinvsW*xf, data.x_shp);
err  = data.fhan(xp, pp)*data.F;
err  = real(err.*conj(err));
err  = sqrt(sum(err(:)));

dft = data.dft;
y   = [err; err/dft.TOL; dft.NMOD];

end %!end_dft_error

% [data Jt] = fdm_ezDFDX('f(o,d,x)', prob, data, @dft_F, u);