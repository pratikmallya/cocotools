function [opts atlas cseg] = init_update_chart(atlas, opts, cseg)
% update tangent space TS
[opts cseg.curr_chart] = cseg.tangent_space(opts, cseg.curr_chart);

% initialise tangents t
cseg.curr_chart.t = cseg.curr_chart.TS * cseg.curr_chart.s;

% update point count
cseg.curr_chart.pt = cseg.curr_chart.pt + 1;
end
