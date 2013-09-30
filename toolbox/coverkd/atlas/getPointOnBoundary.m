function [atlas chart s] = getPointOnBoundary(atlas)
% Search the boundary list for a polyhdron with exterior vertices.

s=[];
v=[];
i=1;
while ~isempty(atlas.boundaryList) && ...
    i<=numel(atlas.boundaryList) && ...
    isempty(v)
  chart=atlas.chart{atlas.boundaryList(i)};
  P=chart.P;
  R=chart.R;
  j=1;
  v=[];
  while j<=numel(P.v) && numel(v)==0
    if norm(P.v{j})>R && P.mark(j)==0
      v=P.v{j};
      s=R*v/norm(v);
      P.mark(j)=1;
      chart.P=P;
      atlas.chart{atlas.boundaryList(i)}=chart;
    end
    j=j+1;
  end
  if isempty(v)
    atlas.boundaryR(i)=[];
    atlas.boundaryList(i)=[];
  else
    i=i+1;
  end
end

end
