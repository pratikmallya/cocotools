function mesh = coll_mesh(int, maps, tmi)

mesh.tmi = tmi;

dim  = int.dim;
NCOL = int.NCOL;
NTST = maps.NTST;

bpnum  = NCOL+1;
xcndim = dim*NCOL*NTST;

ka        = diff(tmi);
mesh.ka   = ka';

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