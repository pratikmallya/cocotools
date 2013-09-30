function [opts atlas cseg accept] = flush(atlas, opts, cseg)
% Flush chart to disk and screen output.

% flush point list
[opts atlas cseg accept] = atlas.flush@AtlasBase(opts, cseg);

if cseg.Status == cseg.CurveSegmentOK
  
  % flush last point into base_chart
  atlas.base_chart = cseg.ptlist{end};
  
  % Stop FSM if accept or It>=ItMX.
  chart  = cseg.ptlist{end};
  accept = accept || (chart.pt>=atlas.cont.ItMX);
  
end

end
