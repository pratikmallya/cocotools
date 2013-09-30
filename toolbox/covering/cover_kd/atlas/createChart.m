function chart=createChart(k, center, R, TS)
% Constructs a chart

chart.k      = k;             % The dimension of the tangent space
chart.id     = 0;             % The sequence number assigned to this chart
chart.center = center;        % The center (in embedding space - nd)
chart.R      = R;             % The chart radius
chart.TS     = TS;            % The tangent space (nxk)
chart.P      = createHyperCube(k, 1.05*R); % The chart's polyhedron

end
