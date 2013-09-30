function [data y xidx] = epval(opts, data, xp)
%Example monitor function returning value at end point.
%

if isempty(data)
  [fdata xidx] = coco_get_func_data(opts, 'coll');
  data.x1idx   = 1;
  xidx         = xidx(fdata.x1idx(1));
  xp           = xp(xidx);
else
  xidx = [];
end

% extract end-point all first segment
y(1,:) = xp;
