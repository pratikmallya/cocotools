function [opts atlas cseg accept] = add_chart(atlas, opts, cseg)

% update tangent space TS
[opts chart] = cseg.tangent_space(opts, cseg.curr_chart);

% compute tangent t
[opts chart] = cseg.tangent(opts, chart);
chart.pt     = chart.pt + 1;

% check if final chart
if chart.pt >= abs(atlas.cont.ItMX)
  chart.pt_type = 'EP';
  chart.ep_flag = 1;
end

% add chart to point list
cseg.ptlist = [ cseg.ptlist chart ];

% accept curve segment
accept = true;
end
