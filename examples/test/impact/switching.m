function [data y xidx] = switching(opts, data, xp)
% switching   Detection of switching
%
%   SWITCHING(OPTS,XP) Expression for h_turning

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'coll');
  seg          = 4;
  x1idx        = fdata.x1idx((seg-1)*3+(1:3));
  p_idx        = fdata.p_idx;
  data.x1idx   = 1:numel(x1idx);
  data.p_idx   = numel(x1idx) + (1:numel(p_idx));
  xidx         = xidx([x1idx ; p_idx]); % select relevant components only
  xp           = xp(xidx);
else
  xidx = [];
end

x      = xp(data.x1idx,:);
p      = xp(data.p_idx,:);

k      = p(3,:);
Ff     = p(2,:);

y(1,:) = k.*x(1,:)+Ff;
