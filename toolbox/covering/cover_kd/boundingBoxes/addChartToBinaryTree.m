% Adds a chart with center and radius to an hierarchical bounding box.


%struct binaryTreeSt {
%                       int nCharts;
%                       int k;
%                       binaryTreeLeaf root;
%                     end;
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
%                   end;

function TRoot=addChartToBinaryTree(TRoot,chartNo,center,R)
  TRoot.root=binaryTreeLeafAddChart(TRoot.root,TRoot.k,chartNo,R,center);
  TRoot.leftB =TRoot.root.leftB;
  TRoot.rightB=TRoot.root.rightB;
end

function T=binaryTreeLeafAddChart(T,k,chart,R,center)
 t=center(T.d);

 if numel(T.leftT)==0 && numel(T.rightT)==0 && T.nCharts<5

% no subdivision and room to insert point.

  if T.nCharts<5

% find the place to insert the new chart.

   n=1;
   while n<T.nCharts && T.value(n)<t
    n=n+1;
   end
   n=n-1;
   
% Insert the new chart (sorted on the d'th coordinate of the center).

   if n>0 && n<numel(T.chart)
    T.chart      =[ T.chart(1:n)         chart    T.chart(n+1:end)       ];
    T.chartR     =[ T.chartR(1:n)        R        T.chartR(n+1:end)      ];
    T.chartCenter=[ T.chartCenter(1:n)   center   T.chartCenter(n+1:end) ];
    T.value      =[ T.value(1:n)         t        T.value(n+1:end)       ];
   elseif n>0 && n+1>numel(T.chart)
    T.chart      =[ T.chart       , chart ];
    T.chartR     =[ T.chartR      , R     ];
    T.chartCenter=[ T.chartCenter , center];
    T.value      =[ T.value       , t     ];
   elseif n==0 && n<numel(T.chart)
    T.chart      =[ chart  , T.chart       ];
    T.chartR     =[ R      , T.chartR      ];
    T.chartCenter=[ center , T.chartCenter ];
    T.value      =[ t      , T.value       ];
   else
    T.chart      =[ chart ];
    T.chartR     =[ R     ];
    T.chartCenter{1}=center;
    T.value      =[ t     ];
   end
    
   T.nCharts=T.nCharts+1;

% Update this leaf's bounding box.

   if(T.nCharts==1)
    T.leftB =center-R*ones(k,1);
    T.rightB=center+R*ones(k,1);
   else
     T.leftB =min(center-R*ones(k,1),T.leftB );
     T.rightB=max(center+R*ones(k,1),T.rightB);
   end
  end

 elseif numel(T.leftT)==0 && numel(T.rightT)==0

% no subdivision and no room to insert point.

% First find the two widest coordinate directions. The widest will split this leaf, the next will 
%   be used to sort the left and right sub-leaves.

  maxwidth=-1.;
  T.split=0.;
  nextmaxwidth=0.;
  nextdir=1;

  for i=1:k
   x0=center(i);
   x1=center(i);
   for j=1:T.nCharts
    if T.chartCenter{j}(i)>x1
     x1=T.chartCenter{j}(i);
    end
    if T.chartCenter{j}(i)<x0
     x0=T.chartCenter{j}(i);
    end
   end
   if x1-x0>maxwidth
    maxwidth=x1-x0;
    T.split=(x1+x0)/2;
    T.d=i;
   elseif x1-x0>nextmaxwidth
    nextmaxwidth=x1-x0;
    nextdir=i;
   end
  end
  
%  Change the split of this leaf.

  for i=1:T.nCharts
   T.value(i)=T.chartCenter{i}(T.d);
  end

% Create sub-leaves

  T.leftT=createBinaryTreeLeaf(k,nextdir);
%  T.leftT.parent=T;
  T.rightT=createBinaryTreeLeaf(k,nextdir);
%  T.rightT.parent=T;

% Move existing charts down into the leaves

  for i=1:T.nCharts
   if T.value(i)<T.split
    T.leftT=binaryTreeLeafAddChart(T.leftT,k,T.chart(i),T.chartR(i),T.chartCenter{i});
   elseif T.value(i)>T.split
    T.rightT=binaryTreeLeafAddChart(T.rightT,k,T.chart(i),T.chartR(i),T.chartCenter{i});
   else
    if T.leftT.nCharts<T.rightT.nCharts
     T.leftT=binaryTreeLeafAddChart(T.leftT,k,T.chart(i),T.chartR(i),T.chartCenter{i});
    else
     T.rightT=binaryTreeLeafAddChart(T.rightT,k,T.chart(i),T.chartR(i),T.chartCenter{i});
    end
   end
  end

% Move added chart down into the leaves

  t=center(T.d);
  if t<T.split
   T.leftT=binaryTreeLeafAddChart(T.leftT,k,chart,R,center);
  elseif t>T.split
   T.rightT=binaryTreeLeafAddChart(T.rightT,k,chart,R,center);
  else
   if T.leftT.nCharts<T.rightT.nCharts
    T.leftT=binaryTreeLeafAddChart(T.leftT,k,chart,R,center);
   else
    binaryTreeLeafAddChart(T.rightT,k,chart,R,center);
   end
  end
  T.chart=[];
  T.chartCenter=[];
  T.value=[];
  T.chartR=[];
  T.nCharts=0;
 else

% This leaf is already subdivided, push chart down.

  t=center(T.d);
  if t<T.split
   T.leftT=binaryTreeLeafAddChart(T.leftT,k,chart,R,center);
  elseif t>T.split
   T.rightT=binaryTreeLeafAddChart(T.rightT,k,chart,R,center);
  elseif T.rightT.nCharts<T.rightT.nCharts
   T.leftT=binaryTreeLeafAddChart(T.leftT,k,chart,R,center);
  else
   T.rightT=binaryTreeLeafAddChart(T.rightT,k,chart,R,center);
  end
 end  

% Update this leaf's bounding box.

 if numel(T.leftT) > 0
  T.leftB  =T.leftT.leftB;
  T.rightB =T.leftT.rightB;
 end
 if numel(T.rightT) > 0
  T.leftB  =min(T.leftB ,T.rightT.leftB );
  T.rightB =max(T.rightB,T.rightT.rightB);
 end
end
