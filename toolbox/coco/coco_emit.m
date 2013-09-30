function [opts varargout] = coco_emit(opts, list, varargin)
%coco_emit   Emit signal to slot list list.
%
%   [OPTS ...] = COCO_emit(OPTS, LIST, ...)
%

signame = lower(list);
if isfield(opts, 'slots') && isfield(opts.slots, signame)
  if ~isfield(opts.signals, signame)
    opts.signals.(signame).warn = false;
    % bug: this should become an error soon
    fprintf(2, 'warning: Attempt to emit undefined signal ''%s''. This will become obsolete.\n', ...
      list);
    fprintf(2, 'Define signal using coco_add_signal to avoid future errors.\n');
  end
  slist = opts.slots.(signame);
  funcs = opts.slots.funcs;
  out   = {};
  lout  = cell(1,nargout-1);
  for i=slist
    lout{1} = funcs(i).identifyer;
    data    = funcs(i).data;
    [data lout{2:end}] = funcs(i).F(opts, data, varargin{:});
    opts.slots.funcs(i).data = data;
    out = [ out ; lout ]; %#ok<AGROW>
  end
  for i=1:nargout-1
    varargout{i} = out(:,i);
  end
else
  [varargout{1:nargout-1}] = deal({});
end
