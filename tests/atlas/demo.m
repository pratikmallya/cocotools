% Tests atlas and boundary

clc;

atlas=createAtlas();

n=1;
c=[0;0;0];
TS=[[1. 0.] ; [0. 1.] ; [0. 0.]];

r=4;
% chart=createChart(2,c,1+0.25*rand,TS);
chart=createChart(2,c,1,TS);
[chart atlas]=addChartToAtlas(atlas,chart,1);

chartMX = 21;
while ~chartMX || (chartMX && chart.id<chartMX)
    [ atlas chart s ] = getPointOnBoundary(atlas);
    if isempty(s)
        break
    end
    c=chart.center+chart.TS*s;
    if all(c>[-r; -r; -r]) && all(c<[r; r; r])
        chart=createChart(2,c,1/sqrt(2),chart.TS);
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
