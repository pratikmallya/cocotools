function opts = coll_create(opts, data, x0, p0, dx0)

fid         = coco_get_id(data.prefix, 'coll_fun');
if ~isempty(dx0)
[opts xidx] = coco_add_func(opts, fid, @coll_F, @coll_DFDX, data, ...
    'zero', 'x0', [x0; p0], 't0', [dx0; zeros(numel(p0),1)]);
else
    [opts xidx] = coco_add_func(opts, fid, @coll_F, @coll_DFDX, data, ...
    'zero', 'x0', [x0; p0]);
end
data.xidx = xidx;

fid  = coco_get_id(data.prefix, 'reduced_coll_save');
opts = coco_add_slot(opts, fid, @coco_save_data, [], 'save_reduced');
fid  = coco_get_id(data.prefix, 'coll_save');
opts = coco_add_slot(opts, fid, @coco_save_data, data, 'save_full');

end

function [data y] = coll_F(opts, data, xp)

x   = xp(data.x_idx);
p   = xp(data.p_idx);
xbp = x(data.xbpidx);
T   = x(data.Tidx);

xx  = reshape(data.W  * xbp, [data.dim data.NTST*data.NCOL]);
pp  = repmat(p, [1 data.NTST*data.NCOL]);

fode  = data.fhan(xx, pp, data.mode);
fode  = reshape(fode, [data.dim*data.NTST*data.NCOL 1]);
fode  = (0.5 * T / data.NTST) * fode - data.Wp * xbp;
fcont = data.Q * xbp;

y = [ fode ; fcont ];

end

function [data J] = coll_DFDX(opts, data, xp)

x   = xp(data.x_idx);
p   = xp(data.p_idx);
xbp = x(data.xbpidx);
T   = x(data.Tidx);

xx  = reshape(data.W * xbp, [data.dim data.NTST*data.NCOL]);
pp  = repmat(p, [1 data.NTST*data.NCOL]);

if isempty(data.dfdxhan)
    dfode = coll_num_DFDX(data.fhan, xx, pp, data.mode);
else
    dfode = data.dfdxhan(xx, pp, data.mode);
end
dfode = reshape(dfode, [data.dim*data.dim*data.NTST*data.NCOL 1]);
dfode = sparse(data.dxrows, data.dxcols, dfode);
dfode = (0.5 * T / data.NTST) * dfode * data.W - data.Wp;

[rows cols vals] = find(dfode);

fode = data.fhan(xx, pp, data.mode);
fode = reshape(fode, [data.dim*data.NTST*data.NCOL 1]);
fode = (0.5 / data.NTST) * fode;
r    = (1:data.dim*data.NTST*data.NCOL)';
c    = repmat(data.dim*(data.NCOL+1)*data.NTST+1, ...
    [data.dim*data.NTST*data.NCOL,1]);

rows = [rows ; r];
cols = [cols ; c];
vals = [vals ; fode];
off  = data.dim*data.NTST*data.NCOL;

[r c v] = find(data.Q);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

J1 = sparse(rows, cols, vals);

if isempty(data.dfdphan)
    dfode = coll_num_DFDP(data.fhan, xx, pp, 1:numel(p), data.mode);
else
    dfode = data.dfdphan(xx, pp, 1:numel(p), data.mode);
end
dfode = reshape(dfode, [data.dim*numel(p)*data.NTST*data.NCOL 1]);
dfode = sparse(data.dprows, data.dpcols, dfode);
dfode = (0.5 * T / data.NTST) * dfode;

if numel(p)>0
    dfcont = sparse(size(data.Q,1), numel(p));
else
    dfcont = [];
end

J2 = [ dfode ; dfcont ];

J = sparse([J1 J2]);

end