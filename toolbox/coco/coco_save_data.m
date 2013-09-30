function [data res] = coco_save_data(opts, data, varargin) %#ok<INUSL>

res = data;
if isfield(res, 'no_save')
  res = rmfield(res, res.no_save);
end
