function varargout = coco_bd_print(runid, mode)

if nargin<2
  mode = 'log';
end

if strcmpi(mode, 'log')
  [fname flag] = coco_fname(runid, 'coco_scr.txt');
  if flag
    s = dir(fname);
    if s.bytes>0
      type(fname);
      return
    end
  end
end

bd = coco_bd_read(runid);
if nargout>=1
  varargout{1} = bd;
end

PT   = coco_bd_col(bd, 'PT', false);
TYPE = coco_bd_col(bd, 'TYPE', false);
LAB  = coco_bd_col(bd, 'LAB', false);
PARN = bd{1,6};
PAR  = coco_bd_col(bd, PARN, false);
NRMU = coco_bd_col(bd, '||U||', false);

fprintf('%5s %4s %5s %11s %11s\n', ...
  'PT', 'TYPE', 'LAB', PARN, '||U||')
for i=1:numel(PT)
  if ~isempty(LAB{i})
    fprintf('%5d %4s %5d % .4e % .4e\n', ...
      PT{i}, pr_type(TYPE{i}), LAB{i}, PAR{i}, NRMU{i})
  end
end

end

function tpname = pr_type(tp)
  switch tp
    case {'RO' 'ROS'}
      tpname = '';
    otherwise
      tpname = tp;
  end
end
