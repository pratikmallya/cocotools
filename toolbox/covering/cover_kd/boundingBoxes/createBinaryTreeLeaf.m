% Creates a leaf for the hierarchical bounding boxes. (internal)

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

% To use parent we need to use this, otherwise assignment of parent to
%  leaf creates a copy.
%
% function TLeaf_ptr=createBinaryTreeLeaf(k,d)
%   TLeaf.d=d;
%   TLeaf.split=0.;
%   TLeaf.nCharts=0;
% 
%   TLeaf.chart=[];
%   TLeaf.chartR=[];
%   TLeaf.chartCenter=cell(0);
% 
%   TLeaf.value=[];
% 
%   TLeaf.leftB=1.e20*ones(1,k);
%   TLeaf.rightB=-1.e20*ones(1,k);
%   TLeaf.parent=[];
%   TLeaf.leftT=[];
%   TLeaf.rightT=[];
%
%   TLeaf_ptr = coco_ptr(TLeaf);
% end

function TLeaf=createBinaryTreeLeaf(k,d)
  TLeaf.d=d;             % the coordinate direction of the split
  TLeaf.split=0.;        % the coordinate value of the split
  TLeaf.nCharts=0;       % the number of charts in this leaf

  TLeaf.chart=[];        % the list of chart numbers in this leaf
  TLeaf.chartR=[];       % the list of chart radii   
  TLeaf.chartCenter=cell(0);  % the list of chart centers

  TLeaf.value=[];        % the split value of each chart

  TLeaf.leftB=1.e20*ones(k,1);    % the lower left corner of this leaf's box
  TLeaf.rightB=-1.e20*ones(k,1);  % the upper right corner of the box
%  TLeaf.parent=[];
  TLeaf.leftT=[];                 % the left leaf
  TLeaf.rightT=[];                % the right leaf
end
