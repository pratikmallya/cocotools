% Constructs an empty hierarchical bounding box.

%struct MFBinaryTreeSt {
%                       int nCharts;
%                       int k;
%                       MFBinaryTreeLeaf root;
%                      };
%
%struct MFBinaryTreeLeafSt {
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
%                     MFBinaryTreeLeaf parent;
%                     MFBinaryTreeLeaf leftT;
%                     MFBinaryTreeLeaf rightT;
%                    };

function Tree = createBinaryTree(k)
  Tree.nCharts=0;
  Tree.k=k;
  Tree.root=createBinaryTreeLeaf(k,1);
  TLeaf.leftT=[];
  TLeaf.rightT=[];
end

