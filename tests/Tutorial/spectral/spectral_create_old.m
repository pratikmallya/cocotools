function opts = spectral_create(opts, data, x0, p0)

fid         = coco_get_id(data.prefix, 'spectral_fun');
opts = coco_add_func(opts, fid, @spectral_F, data, 'zero', 'x0', [x0; p0]);

data.xidx = coco_get_func_data(opts, fid, 'xidx');

fid  = coco_get_id(data.prefix, 'reduced_spectral_save');
opts = coco_add_slot(opts, fid, @coco_save_data, [], 'save_reduced');
fid  = coco_get_id(data.prefix, 'spectral_save');
opts = coco_add_slot(opts, fid, @coco_save_data, data, 'save_full');
fid  = coco_get_id(data.prefix, 'spectral_adapt');
opts = coco_add_slot(opts, fid, @spectral_adapt, data, 'covering_adapt');

opts = coco_add_parameters(opts, '',data.xidx(data.p_idx), 1:data.pdim);

end

function [data y] = spectral_F(opts, data, xp) %#ok<INUSL>

x   = xp(data.x_idx);
p   = xp(data.p_idx);
xsp = x(data.xspidx);
T   = x(data.Tidx);

dim  = data.dim;
NMAX = data.NMAX;
NMOD = data.NMOD;

% xtp = reshape(xsp(dim+1:dim*(2*NMOD+1)), [dim*NMOD 2]);
% xtp = [xsp(1:dim) reshape(xtp(:,1)+1i*xtp(:,2), [dim NMOD])];
% G   = zeros(dim, NMAX);
% G(:,1:NMOD+1)           = NMAX * xtp(:,1:NMOD+1);
% Gt(:,1:NMOD+1)          = 2*pi*1i*repmat(0:NMOD, [dim 1]).*G(:,1:NMOD+1);
% G(:,NMAX+2-(2:NMOD+1))  = conj(G(:,2:NMOD+1));
% Gt(:,NMAX+2-(2:NMOD+1)) = conj(Gt(:,2:NMOD+1));
pp  = repmat(p, [1 data.NMAX]);

xf = xsp(1:dim*(2*NMOD+1));
% fode = fft(T*data.fhan(ifft(G.').', pp, data.mode).').' - Gt;
% fode1 = T*data.fhan(G*data.Finv, pp, data.mode)*data.F - Gt;
% fode1 = T*data.fhan(reshape(data.Finvs*data.W*xsp, [dim NMAX]), pp, data.mode)*data.F - Gt;
% fode1 = reshape(data.Fs*reshape(T*data.fhan(reshape(data.Finvs*data.W*xsp, [dim NMAX]), pp, data.mode), [dim*NMAX 1]), [dim NMAX]) - Gt;
% fode = reshape(data.Fs*reshape(T*data.fhan(reshape(data.Finvs*data.W*xsp, [dim NMAX]), pp, data.mode), [dim*NMAX 1]), [dim NMAX]) - ...
%     reshape(data.Wp*xsp,[dim NMAX]);
% fode = reshape(fode(:,1:NMOD+1), [dim*(NMOD+1), 1]);
G  = data.W*xf;
Gp = data.Wp*xf;
f  = reshape(T*data.fhan(reshape(data.Finvs*G, [dim NMAX]), pp, data.mode), [dim*NMAX 1]);
fode = data.Fs(1:dim*(NMOD+1),:)*f - Gp(1:dim*(NMOD+1));
fdum = xsp(dim*(2*NMOD+1)+1:dim*(NMAX-1));

fphase = atan2(real(G(dim+1)),imag(G(dim+1)))-data.ang0;
y = [fode(1:dim); real(fode(dim+1:end)); imag(fode(dim+1:end)); ...
    fdum; fphase];

end

function [data res] = spectral_adapt(opts, data, sol) %#ok<INUSD,INUSL>
res = [];
end