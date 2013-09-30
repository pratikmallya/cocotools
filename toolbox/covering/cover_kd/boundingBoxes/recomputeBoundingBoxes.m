int MFBINARYTREESEQUENCENUMBER=0;
#define MFBINARYTREEMAXNUMBEROFCHARTS 5

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

% This is for when the radius of a chart changes.

function []=recomputeBoundingBoxes(T,chart,center,R)
  leaf=T.root;

  while leaf.nCharts==0
   if center(leaf.d)<leaf.split
    leaf=leaf.leftT;
   else
    leaf=leaf.rightT;
   end
  end

  for i=1:leaf.nCharts
   if leaf.chart(i)==chart
    leaf.chartR(i)=R;
   end
  end

  for i=1:T.k
   leaf.leftB(i)=center(i)-leaf.chartR(0);
   leaf.rightB(i)=center(i)+leaf.chartR(0);;
   for(j=1;j<leaf.nCharts;j++)
    if center(i)-leaf.chartR(j)<leaf.leftB(i)
     leaf.leftB(i)=center(i)-leaf.chartR(j);
    end
    if center(i)+leaf.chartR(j)>leaf.rightB(i)
     leaf.rightB(i)=center(i)+leaf.chartR(j);
    end
   end
  end
%  leaf=leaf.parent;

  while numels(leaf)!=0
   for i=1:T.k
    if numels(leaf.leftB)!=0
     leaf.leftB(i)=(leaf.leftT).leftB(i);
     if numels(leaf.rightB)!=0&&leaf.leftB(i)>(leaf.leftT).leftB(i)
      leaf.leftB(i)=(leaf.rightT).leftB(i);
     elseif numelse(leaf.rightB)!=0
      leaf.leftB(i)=(leaf.rightT).leftB(i);
     end
    end

    if numels(leaf.rightB)!=0
     leaf.rightB(i)=(leaf.rightT).rightB(i);
     if numels(leaf.leftB)!=0&&leaf.rightB(i)>(leaf.rightT).rightB(i)
      leaf.rightB(i)=(leaf.rightT).rightB(i);
     elseif numels(leaf.leftB)!=0
      leaf.rightB(i)=(leaf.rightT).rightB(i);
     end
    end
   end
%  leaf=leaf.parent;
 end

end
