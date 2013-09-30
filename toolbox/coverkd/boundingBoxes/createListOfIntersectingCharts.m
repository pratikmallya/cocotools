% Finds the charts which overlap the give center and radius.

%struct binaryTreeSt {
%                       int nCharts;
%                       int k;
%                       binaryTreeLeaf root;
%                      };
%
%struct binaryTreeLeafSt {
%                     int sequenceNumber;
%                     int nCharts;
%                     int *chart;
%                     double *chartR;
%                     double **chartCenter;
%                     double *value;
%                     int d;
%                     double split;
%                     double *leftB;
%                     double *rightB;
%                     binaryTreeLeaf parent;
%                     binaryTreeLeaf leftT;
%                     binaryTreeLeaf rightT;
%                    };

function list=createListOfIntersectingCharts(TRoot,chart,center,R)
  list=binaryTreeGetIntersectingCharts(TRoot.root,TRoot.k,[],chart,center,R);
end

function list=binaryTreeGetIntersectingCharts(T,k,list,chart,center,R,n)

  if numel(T)==0
   return;
  end

  if numel(T.leftT)==0 && T.nCharts==0
   return;
  end

% Check Bounding box

  if any(center-R*ones(k,1)-T.rightB > 0 ) || any(center+R*ones(k,1)-T.leftB < 0 )
   return
  end

% Chart Intersects Bounding box, add charts to list, or check sub-trees

  if numel(T.leftT)==0
   for i=1:T.nCharts
    if T.chart(i)~= chart
     if norm(center-T.chartCenter{i}) < R+T.chartR(i)
      list = [ list , T.chart(i) ]; %#ok<AGROW>
     end
    end
   end
  else
    list=binaryTreeGetIntersectingCharts(T.leftT,k,list,chart,center,R);
    list=binaryTreeGetIntersectingCharts(T.rightT,k,list,chart,center,R);
  end

end
