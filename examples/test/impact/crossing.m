function [data y xidx] = crossing(opts, data, xp)
% switching   Detection of crossing
%
%   SWITCHING(OPTS,XP) Expression for h_turning

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'coll');
  seg          = 3;
  x1idx        = fdata.x1idx((seg-1)*3+(1:3));
  data.x1idx   = 1:numel(x1idx);
  xidx         = xidx(x1idx); % select relevant components only
  xp           = xp(xidx);
else
  xidx = [];
end

y(1,:) = xp(2,:);
