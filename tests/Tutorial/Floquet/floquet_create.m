function opts = floquet_create(opts, data, x0)

data_ptr = coco_ptr(data);

[opts xidx] = coco_add_func([], 'floquet_fun', @floquet_F, @floquet_DFDX, ...
    data_ptr, 'zero', 'x0', x0);
data_ptr.data.xidx = xidx;

opts     = coco_add_slot(opts, 'floquet_save', @coco_save_data, ...
    data_ptr, 'save_full');

opts     = coco_add_slot(opts, 'floquet_update', @floquet_update, ...
    data_ptr, 'covering_update');

opts     = coco_add_parameters(opts, '', data.p_idx, 1:numel(data.p_idx));
end

function [data_ptr y] = floquet_F(opts, data_ptr, xp)

data = data_ptr.data;

dim  = data.dim;
NTST = data.NTST;
NCOL = data.NCOL;

x   = xp(data.x_idx); %nN(m+1)+1 x 1
xbp = x(data.xbpidx); %nN(m+1) x 1
T   = x(data.Tidx); %1 x 1
p   = xp(data.p_idx); %p x 1
ubp = xp(data.u_idx); %n^2*N(m+1) x 1

xx  = reshape(data.W  * xbp, [dim NTST*NCOL]); %n x Nm
pp  = repmat(p, [1 NTST*NCOL]); %p x Nm

fvec  = data.fhan(xx, pp, data.mode); % n x Nm
fvec  = reshape(fvec, [dim*NTST*NCOL 1]); % nNm x 1
fode  = (0.5 * T / NTST) * fvec - data.Wp * xbp; %nNm x 1
fcont = data.Q * xbp; % n(N-1) x 1

y = [fode; fcont]; % nNm+n(N-1) x 1

dfvecdx  = data.dfdxhan(xx, pp, data.mode); % n x n x Nm
dfvecdx  = reshape(dfvecdx, [dim*dim*NTST*NCOL 1]); % n^2*Nm x 1
dfvecdx  = sparse(data.dxrows, data.dxcols, dfvecdx); % nNm x nNm
dfodedx  = (0.5 * T / NTST) * dfvecdx * data.W - data.Wp; % nNm x nN(m+1)
dfcontdx = data.Q; % n(N-1) x nN(m+1)

y = [y; kron(eye(dim), dfodedx) * ubp; kron(eye(dim), dfcontdx) * ubp]; % + n^2*Nm + n^2(N-1) x 1

x0 = xbp(data.x0idx); % n x 1
x1 = xbp(data.x1idx); % n x 1
% x1(3) = x1(3) - 2*pi;

y = [y; x0 - x1 ; data.xp0 * (data.W * xbp - data.x0); kron(eye(dim), data.B) * ubp - 3*data.Id]; % + n + 1 + n^2 x 1

end

function [data_ptr J] = floquet_DFDX(opts, data_ptr, xp)

data = data_ptr.data;

dim  = data.dim;
NTST = data.NTST;
NCOL = data.NCOL;

x   = xp(data.x_idx); %nN(m+1)+1 x 1
xbp = x(data.xbpidx); %nN(m+1) x 1
T   = x(data.Tidx); %1 x 1
p   = xp(data.p_idx); %p x 1
ubp = xp(data.u_idx); %n^2*N(m+1) x 1

xx  = reshape(data.W  * xbp, [dim NTST*NCOL]); %n x Nm
pp  = repmat(p, [1 NTST*NCOL]); %p x Nm

fvec  = data.fhan(xx, pp, data.mode); % n x Nm
fvec  = reshape(fvec, [dim*NTST*NCOL 1]); % nNm x 1

dfvecdx  = data.dfdxhan(xx, pp, data.mode); % n x n x Nm
dfvecdx  = reshape(dfvecdx, [dim*dim*NTST*NCOL 1]); % n^2*Nm x 1
dfvecdx  = sparse(data.dxrows, data.dxcols, dfvecdx); % nNm x nNm
dfodedx  = (0.5 * T / NTST) * dfvecdx * data.W - data.Wp; % nNm x nN(m+1)
dfcontdx = data.Q; % n(N-1) x nN(m+1)

[rows cols vals] = find(dfodedx);

dfodedT  = (0.5 / NTST) * fvec;
r    = (1:dim*NTST*NCOL)';
c    = repmat(dim*(NCOL+1)*NTST+1, [dim*NTST*NCOL,1]);

rows = [rows ; r];
cols = [cols ; c];
vals = [vals ; dfodedT];

[r c v] = find(dfcontdx);
rows = [rows ; dim*NTST*NCOL + r];
cols = [cols ; c];
vals = [vals ; v];

J1 = sparse(rows, cols, vals); % nNm + n(N-1) x nN(m+1) + 1

dfvecdp = data.dfdphan(xx, pp, data.mode); % n x p x Nm
dfvecdp = reshape(dfvecdp, [dim*numel(p)*NTST*NCOL 1]); % npNm x 1
dfvecdp = sparse(data.dprows, data.dpcols, dfvecdp); % nNm x p
dfodedp = (0.5 * T / data.NTST) * dfvecdp; % nNm x p

if numel(p)>0
    dfcontdp = sparse(size(data.Q,1), numel(p)); % n(N-1) x p
else
    dfcontdp = [];
end

J2 = [ dfodedp ; dfcontdp ]; % nNm + n(N-1) x p

J = sparse([J1 J2 sparse(dim*NTST*(NCOL+1)-dim, dim*dim*NTST*(NCOL+1))]); % nNm + n(N-1) x nN(m+1) + 1 + p + n^2*N(m+1)

dfvecdxdx = data.dfdxdxhan(xx, pp, data.mode); % n x n x n x Nm
dfvecdxdx = reshape(dfvecdxdx, [dim*dim*dim*NTST*NCOL 1]); % n^3*Nm x 1
dfvecdxdx = sparse(data.dxdxrows1, data.dxdxcols1, dfvecdxdx); % n^2*Nm x nNm
dfodedxdx = reshape(dfvecdxdx * data.W, [dim*dim*dim*NTST*NTST*NCOL*(NCOL+1) 1]); % n^3*N^2*m(m+1) x 1
dfodedxdx = sparse(data.dxdxrows2, data.dxdxcols2, dfodedxdx) * data.W * reshape(ubp, [dim*NTST*(NCOL+1) dim]); % n^2*N^2*m(m+1) x n
dfodedxdx = reshape(dfodedxdx, [dim*dim*dim*NTST*NTST*NCOL*(NCOL+1) 1]); % n^3*N^2*m(m+1) x 1
dfodedxdx = (0.5 * T / NTST) * sparse(data.dxdxrows3, data.dxdxcols3, dfodedxdx); % n^2*Nm x nN(m+1)

dfodedxdT = kron(eye(dim), (0.5 / NTST) * dfvecdx * data.W) * ubp;

dfvecdxdp = data.dfdxdphan(xx, pp, data.mode); % n x n x Nm x p
dfvecdxdp = reshape(dfvecdxdp, [dim*dim*numel(p)*NTST*NCOL 1]); % n^2*Nmp x 1
dfodedxdp = sparse(data.dxdprows1, data.dxdpcols1, dfvecdxdp) * data.W * reshape(ubp, [dim*NTST*(NCOL+1) dim]); % nNmp x n
dfodedxdp = reshape(dfodedxdp, [dim*dim*NTST*NCOL*numel(p) 1]); % n^2*Nmp x 1
dfodedxdp = (0.5 * T / NTST) * sparse(data.dxdprows2, data.dxdpcols2, dfodedxdp); % n^2*Nm x p

dfodedxdu = kron(eye(dim), (0.5 * T / NTST) * dfvecdx * data.W - data.Wp);

J = [J; dfodedxdx dfodedxdT dfodedxdp dfodedxdu];

J = [J ; sparse([sparse(dim*dim*(NTST-1),dim*NTST*(NCOL+1)+1+numel(p)), kron(eye(dim), dfcontdx)])];

Jtemp = sparse([eye(dim) sparse(dim, dim*NTST*(NCOL+1)-2*dim) -eye(dim); data.xp0 * data.W; sparse(dim*dim, dim*NTST*(NCOL+1))]);
Jtemp = sparse([Jtemp sparse(1+dim+dim*dim,1+numel(p))]);
Jtemp = sparse([Jtemp [sparse(1+dim, dim*dim*NTST*(NCOL+1)); kron(eye(dim), data.B)]]);

J = [J; Jtemp];
end

function data_ptr = floquet_update(opts, data_ptr, cmd, varargin)

data = data_ptr.data;

switch cmd
    case 'update'
        x        = varargin{1};
        xbp      = x(data.xbpidx);
        data.x0  = data.W  * xbp;
        xp0      = data.Wp * xbp;
        data.xp0 = (data.wt .* xp0)';
    
        xbp0     = reshape(x(data.u_idx), data.var2x0reshape);
        data.B   = data.B1 + xbp0' * data.B2;
    otherwise
end

data_ptr.data = data;
end