function [data y] = hspo_eigs(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid{1}, 'data');
edim  = fdata.dim;
P     = speye(edim);
for i=1:data.nsegs
  M   = data.M{i};
  dim = size(M,2);
  M0   = M(1:dim,:);
  M1   = M(end-dim+1:end,:);

  [fdata uidx] = coco_get_func_data(prob, data.tbid{i}, 'data', 'uidx');
  utmp = u(uidx);
  p    = utmp(fdata.p_idx);
  x1   = utmp(fdata.x1_idx);
  fs   = fdata.fhan(x1, p, fdata.mode);
  hx   = data.bc_data.dhdxhan(x1, p, data.bc_data.events{i});
  gx   = data.bc_data.dgdxhan(x1, p, data.bc_data.resets{i});
  deye = speye(fdata.dim);
  P    = gx*(deye-(fs*hx)/(hx*fs))*M1/M0*P;
end
y   = eig(P);

end

function [data y] = hspo_eigs_bddat(prob, data, u)

fdata = coco_get_func_data(prob, data.tbid{1}, 'data');
edim  = fdata.dim;
P     = speye(edim);
for i=1:data.nsegs
  M   = data.M{i};
  dim = size(M,2);
  M0   = M(1:dim,:);
  M1   = M(end-dim+1:end,:);

  [fdata uidx] = coco_get_func_data(prob, data.tbid{i}, 'data', 'uidx');
  utmp = u(uidx);
  p    = utmp(fdata.p_idx);
  x1   = utmp(fdata.x1_idx);
  fs   = fdata.fhan(x1, p, fdata.mode);
  hx   = data.bc_data.dhdxhan(x1, p, data.bc_data.events{i});
  gx   = data.bc_data.dgdxhan(x1, p, data.bc_data.resets{i});
  deye = speye(fdata.dim);
  P    = gx*(deye-(fs*hx)/(hx*fs))*M1/M0*P;
end
y   = eig(P);

end