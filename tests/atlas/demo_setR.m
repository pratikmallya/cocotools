% Tests atlas and boundary

clc;

atlas=createAtlas();

n=1;
c=[0;0;0];
TS=[[1. 0.] ; [0. 1.] ; [0. 0.]];

r=4;
save_ids = [4 5 8]; % ids of charts to resize

% initialise atlas with a couple of charts
chart=createChart(2,c,1,TS);
[chart atlas]=addChartToAtlas(atlas,chart,1);
for i=1:10
  [ atlas chart s ] = getPointOnBoundary(atlas);
  c=chart.center+chart.TS*s;
  chart=createChart(2,c,1,chart.TS);
  [chart atlas]=addChartToAtlas(atlas,chart,1);
  
  clf;
  plot([-r r r -r -r], [-r -r r r -r], 'k-', 'LineWidth', 3);
  coverkd_plotCovering(atlas, 1,2,3);
  grid on
  axis([-r-1 r+1 -r-1 r+1])
  drawnow;
end

chartMX = 30;
while ~chartMX || (chartMX && chart.id<chartMX)
  [ atlas chart s ] = getPointOnBoundary(atlas);
  if isempty(s)
    break
  end
  if any(chart.id==save_ids)
    atlas = setChartR(atlas, chart, 0.8*chart.R);
    save_ids = setdiff(save_ids, chart.id);
    
    clf;
    plot([-r r r -r -r], [-r -r r r -r], 'k-', 'LineWidth', 3);
    coverkd_plotCovering(atlas, 1,2,3);
    grid on
    axis([-r-1 r+1 -r-1 r+1])
    drawnow;
  end
  c=chart.center+chart.TS*s;
  if all(c>[-r; -r; -r]) && all(c<[r; r; r])
    chart=createChart(2,c,1,chart.TS);
    [chart atlas]=addChartToAtlas(atlas,chart,1);
  end
  
  %%
  
  clf;
  plot([-r r r -r -r], [-r -r r r -r], 'k-', 'LineWidth', 3);
  coverkd_plotCovering(atlas, 1,2,3);
  grid on
  axis([-r-1 r+1 -r-1 r+1])
  drawnow;
end

% [Tri X] = coverkd_triangulate(atlas);
% trimesh(Tri, X(:,1), X(:,2), X(:,3));
