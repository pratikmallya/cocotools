function data = coll_init_data(data, t0, x0, p0)

NCOL = data.coll.NCOL;
dim  = size(x0,2);
data.int = coll_interval(NCOL, dim);

NTST = data.coll.NTST;
pdim = numel(p0);
data.maps = coll_maps(data.int, NTST, pdim);

t  = linspace(0, NTST, numel(t0));
tt = interp1(t, t0, 0:NTST, 'linear');
tt = tt*(NTST/tt(end));
data.mesh = coll_mesh(data.int, data.maps, tt);

end