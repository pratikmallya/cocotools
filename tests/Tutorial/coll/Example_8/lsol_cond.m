function prob = lsol_cond(prob)
prob = coco_add_func(prob, 'cond', @lsol_cond_TF, [], ...
  'regular', 'lsol.cond', 'PassChart', 'uidx', 'all');
end

function [data chart y] = lsol_cond_TF(prob, data, chart, u)

cdata = coco_get_chart_data(chart, 'lsol');
if isfield(cdata, 'cond')
  y = cdata.cond;
else
  y = nan;
end

end
