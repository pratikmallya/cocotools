function [opts atlas chart accept] = init_chart(atlas, opts, chart)
% construct initial continuation direction
if all(chart.t == 0)
  if numel(opts.efunc.p_idx)>=1
    % go in direction of first active parameter
    fp_idx = opts.efunc.p_idx(1);
  else
    % go in direction of last component of x
    fp_idx = opts.efunc.x_idx(end);
  end
  chart.t(fp_idx) = 1;
end

% Initialize initial chart
chart.TS      = chart.t;
chart.R       = atlas.cont.h;
chart.s       = sign(atlas.cont.ItMX);
chart.pt      = -1;

% request correction of initial point
accept = false;
end
