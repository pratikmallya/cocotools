function [opts atlas cseg accept] = init_atlas(atlas, opts, cseg)

chart         = cseg.curr_chart;
chart.pt_type = 'EP';
chart.ep_flag = 1;

% Insert chart in point list
atlas.base_chart = chart;
cseg.ptlist = { chart };

% insert first chart into point list
if chart.s>0
  opts = AtlasBase.bddat_set(opts, 'ins_mode', 'append');
else
  opts = AtlasBase.bddat_set(opts, 'ins_mode', 'prepend');
end

% Flush curve segment.
accept = true;
end
