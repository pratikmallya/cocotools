function opts = coll_create(opts, data, x0, p0, dx0)

if ~isempty(dx0)
  opts = coco_add_func(opts, data.tbid, @coll_F, @coll_DFDX, data, ...
    'zero', 'x0', [x0; p0], 't0', [dx0; zeros(numel(p0),1)]);
else
  opts = coco_add_func(opts, data.tbid, @coll_F, @coll_DFDX, data, ...
    'zero', 'x0', [x0; p0]);
end
opts = coco_add_slot(opts, data.tbid, @coco_save_data, data, 'save_full');

xidx  = coco_get_func_data(opts, data.tbid, 'xidx');
fid   = coco_get_id(data.tbid, 'err');
fidTF = coco_get_id(data.tbid, 'err_TF');
opts  = coco_add_func(opts, fid, @coll_err, data, ...
  'regular', {fid fidTF}, 'xidx', xidx);

opts = coco_add_event(opts, 'MXCL', 'MX', fidTF, '>', 1);

end

function [data y] = coll_F(opts, data, xp) %#ok<INUSL>

x   = xp(data.x_idx);
p   = xp(data.p_idx);
xbp = x(data.xbpidx);
T   = x(data.Tidx);

NTST = data.coll.NTST;

xx  = reshape(data.W  * xbp, data.xx_shape);
pp  = repmat(p, data.pp_shape);

fode  = data.fhan(xx, pp, data.mode);
fode  = (0.5 * T / NTST) * fode(:) - data.Wp * xbp;
fcont = data.Q * xbp;

y = [ fode ; fcont ];

end

function [data J] = coll_DFDX(opts, data, xp) %#ok<INUSL>

x   = xp(data.x_idx);
p   = xp(data.p_idx);
xbp = x(data.xbpidx);
T   = x(data.Tidx);

NTST = data.coll.NTST;

xx  = reshape(data.W * xbp, data.xx_shape);
pp  = repmat(p, data.pp_shape);

if isempty(data.dfdxhan)
  dfode = coll_num_DFDX(data.fhan, xx, pp, data.mode);
else
  dfode = data.dfdxhan(xx, pp, data.mode);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5 * T / NTST) * dfode * data.W - data.Wp;

[rows cols vals] = find(dfode);

fode = data.fhan(xx, pp, data.mode);
fode = (0.5 / NTST) * fode;

rows = [rows(:); data.frows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.fcols(:); data.Qcols(:)];
vals = [vals(:); fode(:); data.Qvals(:)];

J1 = sparse(rows, cols, vals);

if isempty(data.dfdphan)
  dfode = coll_num_DFDP(data.fhan, xx, pp, 1:numel(p), data.mode);
else
  dfode = data.dfdphan(xx, pp, data.mode);
end
dfode = sparse(data.dprows, data.dpcols, dfode(:));
dfode = (0.5 * T / NTST) * dfode;

if numel(p)>0
  dfcont = sparse(size(data.Q,1), numel(p));
else
  dfcont = [];
end

J2 = [dfode; dfcont];
J = sparse([J1 J2]);

end

function [data y] = coll_err(opts, data, xp) %#ok<INUSL>

dim  = data.dim;
NTST = data.coll.NTST;

u  = xp (data.xbpidx);

cp = reshape(data.Wc*u, [dim NTST]);
cp = sqrt(sum(cp.^2,1));
y  = data.wn * max(cp);
y  = [y;y/data.coll.TOL];

end
