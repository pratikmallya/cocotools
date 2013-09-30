function chart = createChartFromChart(src, R)
% Constructs a chart

chart.k      = src.k;
chart.id     = 0;
chart.center = src.center;
chart.R      = R;
chart.TS     = src.TS;
chart.P      = createHyperCube(src.k, R);

skip  = { 'k' 'id' 'center' 'R' 'TS' 'P' };
names = setdiff(fieldnames(src), skip);

for i=1:numel(names)
  chart.(names{i}) = src.(names{i});
end

end
