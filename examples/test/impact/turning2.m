function [data y xidx] = turning2(opts, data, xp)
% TURNING   Detection of grazing
%
%   TURNING(OPTS,XP) Expression for h_turning

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'coll');
  seg          = 3;
  x1idx        = fdata.x1idx((seg-1)*3+(1:3));
  p_idx        = fdata.p_idx;
  data.x1idx   = 1:numel(x1idx);
  data.p_idx   = numel(x1idx) + (1:numel(p_idx));
  xidx         = xidx([x1idx ; p_idx]); % select relevant components only
  xp           = xp(xidx);
else
  xidx = [];
end

x        = xp(data.x1idx,:);
p        = xp(data.p_idx,:);
[data y] = ev_impact(opts,data,x,p);
