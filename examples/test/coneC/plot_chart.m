function data = plot_chart(opts, data)

fdata = coco_get_func_data(opts, 'alcont', 'data');

if data.mode == 1
  chart = opts.cont.ptlist{end};
  x = chart.x(fdata.p_idx(1));
  y = chart.x(fdata.p_idx(2));
  z = chart.x(fdata.x_idx(1));
else
  x = opts.nwtn.x0(fdata.p_idx(1));
  y = opts.nwtn.x0(fdata.p_idx(2));
  z = opts.nwtn.x0(fdata.x_idx(1));
end

hold on
plot3(x, y, z, data.lt);
hold off
drawnow

end
