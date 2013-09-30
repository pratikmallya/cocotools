function [opts chart] = charts_pop(opts)
%CHARTS_POP   Pop a chart off the atlas.

atlas           = opts.cont.atlas;
[atlas chart s] = getPointOnBoundary(atlas);
opts.cont.atlas = atlas;

if isempty(s)
  chart = [];
else
  chart.x = chart.center;
  chart.s = s/chart.R;
  chart.t = chart.TS*chart.s;
  chart.h = chart.R;
end
