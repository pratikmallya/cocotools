%!hspo_add_bifus
function prob = hspo_add_bifus(prob, oid, tbid, data)

cids = {};
vids = {};
msid = coco_get_id(oid, 'msbvp');
for i=1:numel(data.modes)
  soid = coco_get_id(msid,sprintf('seg%d', i));
  prob = var_coll_add(prob, soid);
  cids = [cids {coco_get_id(soid, 'coll')}];
  vids = [vids {coco_get_id(soid, 'var')}];
end
data.msid = msid;
data.cids = cids;
data.vids = vids;
[fdata uidx] = coco_get_func_data(prob, msid, 'data', 'uidx');
data.p_idx = numel(fdata.x1_idx)+(1:numel(fdata.p_idx));
tfid = coco_get_id(tbid, 'test');
data.tfid = tfid;
tfps = coco_get_id(tfid, {'SN' 'PD' 'NS' 'stab'});
prob = coco_add_chart_data(prob, tfid, [], []);
prob = coco_add_func(prob, tfid, @hspo_TF, data, 'regular', tfps, ...
  'uidx', [uidx(fdata.x1_idx); uidx(fdata.p_idx)], ...
  'requires', vids, 'passChart');
prob = coco_add_event(prob, 'SN', tfps{1}, 0);
prob = coco_add_event(prob, 'PD', tfps{2}, 0);
prob = coco_add_event(prob, @hspo_NS_han, data, 'SP', tfps{3}, 0);

end %!end_hspo_add_bifus
%!hspo_TF
function [data chart y] = hspo_TF(prob, data, chart, u)

cdata = coco_get_chart_data(chart, data.tfid);
if ~isempty(cdata) && isfield(cdata, 'la')
  la = cdata.la;
else
  P = hspo_P(prob, data, u);
  M = P{1};
  for i=2:data.nsegs
    M = P{i}*M;
  end
  la = eig(M);
  chart = coco_set_chart_data(chart, data.tfid, struct('la', la));
end
y(1,1) = prod(la-1);
y(2,1) = prod(la+1);
if numel(la)>1
  NS_TF  = la(data.la_idx1).*la(data.la_idx2);
  y(3,1) = prod(NS_TF(:)-1);
else
  y(3,1) = 1;
end
y(4,1) = sum(abs(la)>1);

end %!end_hspo_TF