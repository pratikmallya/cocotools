function opts = calcvar_create(opts, data, x0, p0)

fid  = coco_get_id(data.prefix, 'calcvar_fun');
opts = coco_add_func(opts, fid, @calcvar_F, @calcvar_DFDX, data, ...
    'zero', 'x0', [x0 ; p0]);
xidx = coco_get_func_data(opts, fid, 'xidx');

fid  = coco_get_id(data.prefix, 'calcvar_save');
opts = coco_add_slot(opts, fid, @coco_save_data, data, 'save_full');


if isempty(data.prefix)
    defaults.ParNames   = {};
    copts = coco_get(opts, 'calcvar');
    copts = coco_merge(defaults, copts);
    if isempty(copts.ParNames)
        opts = coco_add_pars(opts, 'calcvar_pars', ...
            xidx(data.p_idx), 1:numel(data.p_idx));
    else
        opts = coco_add_pars(opts, 'calcvar_pars', ...
            xidx(data.p_idx), copts.ParNames);
    end
end

end

function [data y] = calcvar_F(opts, data, xp)

x   = xp(data.x_idx);
p   = xp(data.p_idx);

f  = data.W  * x;
fp = (2*data.NTST) * data.Wp * x;
pp = repmat(p, [data.NTST*data.NCOL 1]);

dLdf  = data.fhan(f, fp, pp, 'dLdf');
dLdfp = (2 * data.NTST) * data.fhan(f, fp, pp, 'dLdfp');

fint  = (0.5 / data.NTST) * (data.W' * data.wt * dLdf...
    + data.Wp' * data.wt * dLdfp);
fint(data.fint1_idx) = fint(data.fint1_idx) + fint(data.fint2_idx);
fint  = fint(data.fint3_idx);
fcont = data.Q * x;
fbound = [x(1) - 1; x(data.NTST*(data.NCOL+1)) - p];

y = [fint; fcont; fbound];

end

function [data J] = calcvar_DFDX(opts, data, xp)

x   = xp(data.x_idx);
p   = xp(data.p_idx);

f  = data.W  * x;
fp = (2*data.NTST) * data.Wp * x;
pp  = repmat(p, [data.NTST*data.NCOL 1]);

d2Ldfdf   = data.fhan(f, fp, pp, 'd2Ldfdf');
d2Ldfdf   = spdiags(d2Ldfdf,0,data.NTST*data.NCOL,data.NTST*data.NCOL);
d2Ldfpdf  = (2 * data.NTST) * data.fhan(f, fp, pp, 'd2Ldfpdf');
d2Ldfpdf  = spdiags(d2Ldfpdf,0,data.NTST*data.NCOL,data.NTST*data.NCOL);
d2Ldfpdfp = (2 * data.NTST)^2 * data.fhan(f, fp, pp, 'd2Ldfpdfp');
d2Ldfpdfp = spdiags(d2Ldfpdfp,0,data.NTST*data.NCOL,data.NTST*data.NCOL);

Jint = (0.5 / data.NTST) *...
    (data.W'*data.wt*(d2Ldfdf*data.W + d2Ldfpdf*data.Wp) +...
    data.Wp'*data.wt*(d2Ldfpdf*data.W + d2Ldfpdfp*data.Wp));
Jint(data.fint1_idx,:) = Jint(data.fint1_idx,:) + Jint(data.fint2_idx,:);
Jint = Jint(data.fint3_idx,:);

[rows cols vals] = find(Jint);

off  = data.NTST*data.NCOL-1;

[r c v] = find(data.Q);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

off = off + data.NTST - 1;

rows = [rows ; off + [1; 2]];
cols = [cols ; 1; data.NTST*(data.NCOL+1)];
vals = [vals ; 1 ; 1];

J1 = sparse(rows, cols, vals);

J2 = [zeros(data.NTST*(data.NCOL+1)-2,1); 0; -1];

J = sparse([J1 J2]);

end