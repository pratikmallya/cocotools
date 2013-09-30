function [data x1 dx1] = coll_system(data, t0, x0, p0, dx0, dT0)

coll = data.coll;

NTST = coll.NTST;
NCOL = coll.NCOL;
dim  = size(x0,2);
pdim = numel(p0);

data.int  = coll_interval(NCOL, dim);
data.maps = coll_maps(data.int, NTST, pdim);

switch coll.mesh
  case 'uniform'
    tt = 0:NTST;
  case {'frozen' 'moving'}
    t  = linspace(0,NTST,numel(t0));
    tt = interp1(t,t0,0:NTST,'linear');
    tt = tt*(NTST/tt(end));
end

data.mesh = coll_mesh(data.int, data.maps, tt);

T0 = t0(end) - t0(1);
if abs(T0)>eps
  t0  = (t0 - t0(1)) / T0;
  x1  = interp1(t0,  x0, data.mesh.tbp)';
  dx1 = interp1(t0, dx0, data.mesh.tbp)';
  dx1 = dx1*(norm(dx0(:))/norm(dx1(:)));
else
  x1  = repmat( x0(1,:), (NCOL+1)*NTST)';
  dx1 = repmat(dx0(1,:), (NCOL+1)*NTST)';
end
x1  = [ x1(:) ;  T0];
dx1 = [dx1(:) ; dT0];

end
