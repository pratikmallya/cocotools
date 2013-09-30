function [opts] = charts_setR(opts, chart, R)
%CHARTS_SETR   Change radius of chart.

atlas           = opts.cont.atlas;
atlas           = setChartR(atlas, chart, R);
opts.cont.atlas = atlas;
