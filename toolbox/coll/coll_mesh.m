function mesh = coll_mesh(int, maps, tmi)

mesh.tmi = tmi;

dim  = int.dim;
NCOL = int.NCOL;
pdim = maps.pdim;
NTST = maps.NTST;

bpnum  = NCOL+1;
cndim  = dim*NCOL;
xcnnum = NCOL*NTST;
xcndim = dim*NCOL*NTST;

ka        = diff(tmi);
fka       = kron(ka', ones(dim*NCOL,1));
dxka      = kron(ka', ones(dim*cndim,1));
dpka      = kron(ka', ones(pdim*cndim,1));
mesh.ka   = ka;
mesh.fka  = reshape(fka, [dim xcnnum]);
mesh.dxka = reshape(dxka, [dim dim xcnnum]);
mesh.dpka = reshape(dpka, [dim pdim xcnnum]);

wts       = repmat(int.wt, [dim NTST]);
kas       = kron(ka,ones(dim,NCOL));
mesh.wts1 = wts(1,:);
mesh.kas1 = kas(1,:);
mesh.wts2 = spdiags(wts(:), 0, xcndim, xcndim);
mesh.kas2 = spdiags(kas(:), 0, xcndim, xcndim);

t  = repmat(tmi(1:end-1)/NTST, [bpnum 1]);
tt = repmat((0.5/NTST)*(int.tm+1), [1 NTST]);
tt = t+repmat(ka, [bpnum 1]).*tt;
mesh.tbp = tt(:)/tt(end);

end