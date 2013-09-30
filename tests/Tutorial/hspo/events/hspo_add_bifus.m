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
data.efid = coco_get_id(tbid, 'PD');
prob = coco_add_chart_data(prob, data.efid, [], []);
prob = coco_add_event(prob, @hspo_PD_han, data, tfps{2}, 0);
prob = coco_add_event(prob, @hspo_NS_han, data, tfps{3}, 0);

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
  chart = coco_set_chart_data(chart, data.tfid, ...
    struct('M', M, 'la', la, 'P', {P}));
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
%!hspo_NS_han
function [data cseg msg] = hspo_NS_han(prob, data, cseg, cmd, msg)

switch cmd
  case 'init'
    if isfield(msg, 'finish') || strcmp(msg.action, 'warn')
      msg.action = 'finish';
    elseif strcmp(msg.action, 'locate')
      msg.action = 'warn';
    else
      cdata = coco_get_chart_data(cseg.ptlist{1}, data.tfid);
      la0 = cdata.la;
      cdata = coco_get_chart_data(cseg.ptlist{end}, data.tfid);
      la1 = cdata.la;
      switch abs(sum(sign(abs(la0)-1)) - sum(sign(abs(la1)-1)))
        case 4
          msg.point_type = 'NS';
          msg.action     = 'locate';
        case 0
          msg.point_type = 'NSad';
          if data.alg.NSad
            msg.action   = 'locate';
          else
            msg.action   = 'finish';
          end
        otherwise
          msg.point_type = 'NS';
          msg.action     = 'warn';
          msg.wmsg       = 'could not determine type of event';
      end
      msg.idx = 1;
    end
  case 'check'
    msg.action = 'add';
    msg.finish = true;
end

end %!end_hspo_NS_han
%!hspo_PD_han
function [data cseg msg] = hspo_PD_han(prob, data, cseg, cmd, msg)

switch cmd
  case 'init'
    if isfield(msg, 'finish') || strcmp(msg.action, 'warn')
      msg.action = 'finish';
    elseif strcmp(msg.action, 'locate')
      msg.action = 'warn';
    else
      msg.point_type = 'PD';
      msg.action     = 'locate';
      msg.idx = 1;
    end
  case 'check'
    msg.action = 'add';
    msg.finish = true;
    
    chart   = cseg.curr_chart;
    cdata   = coco_get_chart_data(chart, data.tfid);
    M       = cdata.M;
    [v d]   = eig(M);
    [m idx] = min(diag(d)+1);
    v       = 0.01*v(:,idx);
    
    t0   = {};
    x0   = {};
    for i=1:data.nsegs
      vdata = coco_get_func_data(prob, data.vids{i}, 'data');
      [uidx fdata] = coco_get_func_data(prob, vdata.tbid, ...
        'uidx', 'data');
      u  = chart.x(uidx);
      x  = u(fdata.xbp_idx);
      T  = u(fdata.T_idx);
      p  = u(fdata.p_idx);
      
      x  = reshape(x+vdata.M*v, fdata.xbp_shp)';
      t0 = [t0 {fdata.tbp(fdata.tbp_idx)*T}];
      x0 = [x0 {x(fdata.tbp_idx,:)}];
      v  = cdata.P{i}*v;
    end
    for i=1:data.nsegs
      vdata = coco_get_func_data(prob, data.vids{i}, 'data');
      [uidx fdata] = coco_get_func_data(prob, vdata.tbid, ...
        'uidx', 'data');
      u  = chart.x(uidx);
      x  = u(fdata.xbp_idx);
      T  = u(fdata.T_idx);
      p  = u(fdata.p_idx);
      
      x  = reshape(x+vdata.M*v, fdata.xbp_shp)';
      t0 = [t0 {fdata.tbp(fdata.tbp_idx)*T}];
      x0 = [x0 {x(fdata.tbp_idx,:)}];
      v  = cdata.P{i}*v;
    end
    
    pd        = struct('t0', {t0}, 'x0', {x0}, 'p', {p});
    pd.modes  = [data.modes  data.modes];
    pd.events = [data.events data.events];
    pd.resets = [data.resets data.resets];
    chart = coco_set_chart_data(chart, data.efid, pd);
    cseg.curr_chart = chart;
end

end %!end_hspo_PD_han