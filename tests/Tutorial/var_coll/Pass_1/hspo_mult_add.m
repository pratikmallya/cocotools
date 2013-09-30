%!hspo_mult_add
function prob = hspo_mult_add(prob, segsoid)

cids  = {};
vids  = {};
msid  = coco_get_id(segsoid, 'msbvp');
fdata = coco_get_func_data(prob, msid, 'data');
data  = fdata.bc_data;
for i=1:data.nsegs
  soid = coco_get_id(msid, sprintf('seg%d', i));
  cids = [cids {coco_get_id(soid, 'coll')}];
  vids = [vids {coco_get_id(soid, 'var')}];
end
data.msid   = msid;
data.cids   = cids;
data.vids   = vids;
data.p_idx  = numel(fdata.x1_idx)+(1:numel(fdata.p_idx));
data.mnames = coco_get_id(msid, 'multipliers');
prob = coco_add_slot(prob, data.mnames, @hspo_mult_eigs_bddat, ...
  data, 'bddat');

end %!end_hspo_mult_add
%!hspo_mult_eigs_bddat
function [data res] = hspo_mult_eigs_bddat(prob, data, command, ...
  varargin)

switch command
  case 'init'
    res = {data.mnames};
  case 'data'
    [fdata uidx] = coco_get_func_data(prob, data.msid, 'data', 'uidx');
    chart = varargin{1};
    u     = chart.x(uidx);
    P     = hspo_P(prob, data, u([fdata.x1_idx; fdata.p_idx]));
    M = P{1};
    for i=2:data.nsegs
      M = P{i}*M;
    end
    res = {eig(M)};
end

end %!end_hspo_mult_eigs_bddat
%!hspo_P
function P = hspo_P(prob, data, u)

P = cell(1,data.nsegs);
p = u(data.p_idx);
for i=1:data.nsegs
  fdata = coco_get_func_data(prob, data.vids{i}, 'data');
  M1    = fdata.M(fdata.M1_idx,:);
  dim   = fdata.dim;
  
  fdata = coco_get_func_data(prob, data.cids{i}, 'data');
  x     = u(data.x1_idx{i});
  fs    = fdata.fhan(x, p);
  if ~isempty(data.dhdxhan)
    hx = data.dhdxhan(x, p, data.events{i});
  else
    hx = coco_ezDFDX('f(x,p)v', data.hhan, x, p, data.events{i});
  end
  if ~isempty(data.dgdxhan)
    gx = data.dgdxhan(x, p, data.resets{i});
  else
    gx = coco_ezDFDX('f(x,p)v', data.ghan, x, p, data.resets{i});
  end
  P{i}  = gx*(eye(dim)-(fs*hx)/(hx*fs))*M1;
end

end %!end_hspo_P