function [opts atlas cseg] = predict(atlas, opts, cseg) %#ok<INUSD>

% use pseudo arc-length projection condition
chart      = atlas.base_chart;
pr_cond.x  = chart.x;
pr_cond.TS = chart.TS;
pr_cond.s  = chart.s;
pr_cond.h  = chart.R;

% construct new curve segment
% first point new segment = last point old segment
cseg        = CurveSegment(opts, chart, pr_cond, atlas.cont.interp);
cseg.ptlist = { chart };

% update curr_chart with predicted point
cseg.curr_chart.x = chart.x + chart.R*chart.t;

end
