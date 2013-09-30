function atlas = setChartR(old_atlas, old_chart, R)
% Modify radius of a chart in atlas

atlas = createAtlas();

for i=1:numel(old_atlas.chart)
  chart = old_atlas.chart{i};
  if chart.id == old_chart.id
    chart = createChartFromChart(chart, R);
  else
    chart = createChartFromChart(chart, chart.R);
  end
  [chart atlas] = addChartToAtlas(atlas, chart, chart.BC); %#ok<ASGLU>
end

end
