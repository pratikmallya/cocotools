%!po_create
function prob = po_close_orb(prob, tbid, data)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_slot(prob, tbid, @po_update, data, 'update');
segtbid      = coco_get_id(tbid, 'seg.coll');
[fdata uidx] = coco_get_func_data(prob, segtbid, 'data', 'uidx');
prob = coco_add_func(prob, tbid, @po_F, @po_DFDU, data, 'zero', ...
  'uidx', uidx(fdata.xbp_idx));
fid  = coco_get_id(tbid, 'period');
prob = coco_add_pars(prob, fid, uidx(fdata.T_idx), fid, 'active');
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

if data.po.bifus
  segoid = coco_get_id(tbid, 'seg');
  prob = var_coll_add(prob, segoid);
  data.var_id = coco_get_id(segoid, 'var');
  tfid = coco_get_id(tbid, 'test');
  data.tfid = tfid;
  tfps = coco_get_id(tfid, {'SN' 'PD' 'NS' 'stab'});
  prob = coco_add_chart_data(prob, tfid, [], []);
  prob = coco_add_func(prob, tfid, @po_TF, data, ...
    'regular', tfps, 'requires', data.var_id, 'passChart');
  prob = coco_add_event(prob, 'SN', tfps{1}, 0);
  data.efid = coco_get_id(tbid, 'PD');
  prob = coco_add_chart_data(prob, data.efid, [], []);
  prob = coco_add_event(prob, @po_evhan_PD, data, tfps{2}, 0);
  prob = coco_add_event(prob, @po_evhan_NS, data, tfps{3}, 0);
end

end %!end_po_create
%!po_F
function [data y] = po_F(prob, data, u)

x0 = u(data.x0_idx);
x1 = u(data.x1_idx);

y = [x0-x1; data.xp0*u];

end %!end_po_F
%!po_DFDX
function [data J] = po_DFDU(prob, data, u)
  J = data.J;
end %!end_po_DFDX
%!po_update
function data = po_update(prob, data, cseg, varargin)

fid           = coco_get_id(data.tbid, 'seg.coll');
[fdata uidx]  = coco_get_func_data(prob, fid, 'data', 'uidx');
u             = cseg.src_chart.x;
data.xp0      = u(uidx(fdata.xbp_idx))'*data.intfac;
data.J(end,:) = data.xp0;

end %!end_po_update
%!po_TF
function [data chart y] = po_TF(prob, data, chart, u)

cdata = coco_get_chart_data(chart, data.tfid);
if ~isempty(cdata) && isfield(cdata, 'la')
  la = cdata.la;
else
  fdata    = coco_get_func_data(prob, data.var_id, 'data');
  M        = fdata.M(fdata.M1_idx,:);
  la       = eig(M);
  [vv idx] = sort(abs(la-1));
  la       = la(idx(2:end));
  chart    = coco_set_chart_data(chart, data.tfid, struct('la', la));
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

end %!end_po_TF
%!po_evhan_NS
function [data cseg msg] = po_evhan_NS(prob, data, cseg, cmd, msg)

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
      switch abs(sum(sign(abs(la0)-1))-sum(sign(abs(la1)-1)))
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

end %!end_po_evhan_NS
%!po_evhan_PD
function [data cseg msg] = po_evhan_PD(prob, data, cseg, cmd, msg)

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
    vdata = coco_get_func_data(prob, data.var_id, 'data');
    [uidx fdata] = coco_get_func_data(prob, vdata.tbid, ...
      'uidx', 'data');
    chart = cseg.curr_chart;
    u = chart.x(uidx);
    x = u(fdata.xbp_idx);
    T = u(fdata.T_idx);
    p = u(fdata.p_idx);
    
    M     = vdata.M;
    M1    = M(vdata.M1_idx,:);
    [v d] = eig(M1);
    [m i] = min(diag(d)+1);
    xp1   = reshape(x+0.01*M*v(:,i), fdata.xbp_shp)';
    xp1   = xp1(fdata.tbp_idx,:);
    t1    = fdata.tbp(fdata.tbp_idx)*T;
    xp2   = reshape(x-0.01*M*v(:,i), fdata.xbp_shp)';
    xp2   = xp2(fdata.tbp_idx,:);
    t2    = fdata.tbp(fdata.tbp_idx)*T;
    x0    = [xp1; xp2(2:end,:)];
    t0    = [t1; T+t2(2:end)];
    chart = coco_set_chart_data(chart, data.efid, ...
      struct('pd_x0', x0, 'pd_t0', t0, 'pd_p', p));
    cseg.curr_chart = chart;
end

end %!end_po_evhan_PD