function [tri X C] = plot_cuspsurf(charts, ix, iy, iz)
if nargin>=4
  f = @(x) x([ix iy iz])';
else
  f = @(x) x';
end
tri = [];
X   = [];
C   = [];
ghostcharts = find(cellfun(@(x)x.ep_flag>1,charts));
N   = numel(charts);
for k=1:N
  chart = charts{k};
  X     = [ X ; f(chart.x) ];
  ic    = [chart.nb chart.nb(1)];
  ix    = chart.id;
  for l=1:numel(ic)-1
    face = sort([ix ic(l) ic(l+1)]);
    if all(face>0) && ~ismember(face, tri, 'rows')
      tri  = [tri ; face];
      if any(ismember(face,ghostcharts))
        C = [ C ; N+1 ];
      else
        C = [ C ; 1];%k   ];
      end
    end
  end
end
if nargout==0
  % make sure color range is used
  X   = [ X ; X(1,:) ];
  tri = [ tri ; N+1 N+1 N+1 ; N+1 N+1 N+1 ];
  C   = [ C ; 1 ; N+1 ];
  if nargin>=4
    colormap(gca, [lines(numel(charts)) ; 1 1 1]);
    trisurf(tri, X(:,1), X(:,2), abs(X(:,3)), 'FaceColor', 0.8*[1 1 1], ...
      'EdgeColor', 0.7*[1 1 1], 'LineWidth', 0.5);
  end
  clear tri X C
end
end
