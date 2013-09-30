function data = coll_get_settings(prob, tbid, data)
% 7.2.3  An embeddable generalized constructor
%
% DATA = COLL_GET_SETTINGS(PROB, TBID, DATA)
%
% Read collocation toolbox options.
%
%   See also: coll_v1

defaults.NTST = 10;
defaults.NCOL = 4;
if ~isfield(data, 'coll')
  data.coll = [];
end
data.coll = coco_merge(defaults, coco_merge(data.coll, ...
  coco_get(prob, tbid)));
NTST = data.coll.NTST;
assert(numel(NTST)==1 && isnumeric(NTST) && mod(NTST,1)==0, ...
  '%s: input for option ''NTST'' is not an integer', tbid);
NCOL = data.coll.NCOL;
assert(numel(NCOL)==1 && isnumeric(NCOL) && mod(NCOL,1)==0, ...
  '%s: input for option ''NCOL'' is not an integer', tbid);

end