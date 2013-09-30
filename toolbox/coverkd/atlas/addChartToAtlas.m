function [chart1 atlas]=addChartToAtlas(atlas,chart1,addToBoundaryList)
% Adds a chart to an atlas

chart1.id = numel(atlas.chart)+1;
chart1.BC = addToBoundaryList;
if numel(atlas.boundingBox)==0
  atlas.boundingBox=createBinaryTree(numel(chart1.center));
else
  list=createListOfIntersectingCharts(atlas.boundingBox,-1,chart1.center,chart1.R);
  R=chart1.R;
  
  for i=1:numel(list)
    %%
    chart2=atlas.chart{list(i)};
    R2=chart2.R;
    dir=chart2.center-chart1.center;
    %%
    nrm=chart1.TS'*dir;
    dist=norm(dir);
    nrm=nrm/norm(nrm);
    
    onrm=.5*(dist*dist+R*R-R2*R2)/dist;
    
    atlas. nrm=[atlas.nrm  nrm];
    atlas.onrm=[atlas.onrm onrm];
    atlas.oppo=[atlas.oppo chart2.id];
    halfSpace=numel(atlas.nrm)+2*chart1.k;
    
    chart1.P =subtractHalfSpaceFromPoly(chart1.P,halfSpace,nrm,onrm);
    %%
    onrm=.5*(dist*dist+R2*R2-R*R)/dist;
    nrm=-chart2.TS'*dir;
    nrm=nrm/norm(nrm);
    
    atlas. nrm=[atlas.nrm  nrm];
    atlas.onrm=[atlas.onrm onrm];
    atlas.oppo=[atlas.oppo chart1.id];
    halfSpace=numel(atlas.nrm)+2*chart1.k;
    chart2.P=subtractHalfSpaceFromPoly(chart2.P,halfSpace,nrm,onrm);
    
    atlas.chart{list(i)}=chart2;
  end
end
atlas.chart=[atlas.chart chart1];
if addToBoundaryList~=0
  idx = find(atlas.boundaryR>chart1.R, 1);
  if isempty(idx)
    atlas.boundaryR   =[atlas.boundaryR    chart1.R ];
    atlas.boundaryList=[atlas.boundaryList chart1.id];
  else
    atlas.boundaryR   =[ ...
      atlas.boundaryR(1:idx-1) chart1.R atlas.boundaryR(idx:end)];
    atlas.boundaryList=[ ...
      atlas.boundaryList(1:idx-1) chart1.id atlas.boundaryList(idx:end)];
  end
end
atlas.boundingBox=addChartToBinaryTree(atlas.boundingBox,chart1.id,chart1.center,chart1.R);
end
