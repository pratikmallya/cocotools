function [opts] = charts_push(opts, chart, bp_flag)
%CHARTS_PUSH   Add a chart to atlas.

atlas           = opts.cont.atlas;
chart.center    = chart.x;
[chart atlas]   = addChartToAtlas(atlas, chart, bp_flag); %#ok<ASGLU>
opts.cont.atlas = atlas;
