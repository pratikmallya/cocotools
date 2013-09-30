function [mesh ka] = coll_mesh(int, maps, tmi)

NTST = maps.NTST;
NCOL = maps.NCOL;
dim  = maps.dim;
pdim = maps.pdim;
ka   = diff(tmi,1,2);

mesh.NTST = NTST;
mesh.NCOL = NCOL;
mesh.dim  = dim;
mesh.pdim = pdim;

mesh.ka   = ka;
mesh.fka  = kron(ka,ones(dim,NCOL));
mesh.dxka = reshape(kron(mesh.fka,ones(1, dim)), [dim  dim NCOL*NTST]);
mesh.dpka = reshape(kron(mesh.fka,ones(1,pdim)), [dim pdim NCOL*NTST]);

t  = tmi(1:end-1)' / NTST;
tt = repmat(int.tk, [NTST 1]);
tt = (tt+1) * 0.5/NTST;
tt = repmat(ka', [1 NCOL+1]).*tt;
tt = tt + repmat(t, [1 NCOL+1]);
tt = reshape(tt', [NTST*(NCOL+1) 1]);
tt = tt./tt(end);

mesh.tmi = tmi;
mesh.tbp = tt;

end
