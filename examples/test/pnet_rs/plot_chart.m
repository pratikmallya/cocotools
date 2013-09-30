function data = plot_chart(opts, data)

if isempty(opts.cont.ptlist)
  return
end

if ~isfield(data, 'idx')
  [fdata xidx] = coco_get_func_data(opts, 'coll', 'data', 'xidx');
  data.idx     = xidx( ...
    [fdata.p_idx(1:2)' fdata.x_idx(1:2) ...
    fdata.tintidx]);
  data.xidx = xidx(fdata.x_idx);
  data.W    = fdata.W;
  data.xshape = fdata.xshape;
  data.count = 0;
  fprintf(2, 'plot_chart: idx = [%d %d %d %d]\n', ...
    data.idx(1), data.idx(2), data.idx(3), data.idx(4) );
end

if data.mode == 1
  chart = opts.cont.ptlist{1};
  x  = chart.x(data.idx);
  xx = reshape(data.W*chart.x(data.xidx), data.xshape);
else
  x = opts.nwtn.x0(data.idx);
  xx = reshape(data.W*chart.x(data.xidx), data.xshape);
end

% z = reshape(fdata.W*z, fdata.xshape);
% z = sum(z.*z, 1);
% z = sqrt(sum(z)/numel(z));

hold on
plot3( x(1), x(3), x(2), data.lt );
% plot3( x(3), x(4), x(5), data.lt );
% if ~mod(data.count,20)
%   plot3( xx(3,:), xx(1,:), xx(2,:), 'b-' );
% end
% data.count = data.count + 1;
hold off
drawnow

% atlas = opts.cont.atlas;
% fprintf(' %d', atlas.boundaryList); fprintf('\n');
% clf
% coverkd_plotCovering(atlas, ...
%   data.idx(3), data.idx(2), data.idx(4));
% view(2)
% grid on
% drawnow

end
