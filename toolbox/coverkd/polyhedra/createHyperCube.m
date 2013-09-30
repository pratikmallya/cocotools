%  struct MFPolytopeSt{
%                  int k;                /* Dimension of the vertices */
%                  int n;                /* Number of vertices */
%                  double R;             /* Radius */
%                  int m;                /* Space for vertices */
%                  double *v;            /* vertices */
%                  int *nIndices;        /* Number of indices for each vertex */
%                  int *mIndices;        /* Space for indices for each vertex */
%                  int **indices;        /* Indices of each vertex */
%                  int *mark;            /* Mark on each vertex */
%  
%                  int nFaces;
%                  int mFaces;
%                  int *face;          /* Index of face */
%                  int *nFaceV;        /* Number of vertices on each face */
%                  MFKVector *faceN;   /* Normal of face */
%                  double *faceO;      /* Origin of face */
%                 };

function P=createHyperCube(k, R)
% Constructs a k dimensional hypercube with vertex coordinates +/-R

P.k = k;
P.n = 2^k;
P.v = {};

P.nIndices = zeros(1,P.n);
P.indices  = cell(1,P.n);

P.mark =zeros(1,P.n);
c      = -R*ones(k,1);

for i=1:P.n
  P.v{i}=c;
  P.nIndices(i)=k;
  
  for j=1:k
    if c(j)<0
      P.indices{i}(j)=2*j-1;
    else
      P.indices{i}(j)=2*j;
    end
  end
  
  carry=1;
  j=1;
  while carry && j<=k
    if c(j)<0
      c(j)=R;
      carry=0;
    else
      c(j)=-R;
      carry=1;
      j=j+1;
    end
  end
end

P.nFaces=2*k;
P.face=zeros(1,P.nFaces);

P.nFaceV=zeros(1,P.nFaces);
P.faceN=cell(1,P.nFaces);
P.faceV=cell(1,P.nFaces);

P.faceO=zeros(1,P.nFaces);

for i=1:2*k
  P.face(i)=i;
  P.nFaceV(i)=0;
  P.faceN{i}=zeros(k,1);
  if mod(i,2)==0
    P.faceN{i}(i/2)=-1;
  else
    P.faceN{i}((i+1)/2)=1;
  end
  P.faceO(i)=R;
end

for i=1:P.n
  for j=1:P.nIndices(i)
    P.nFaceV(P.indices{i}(j))=P.nFaceV(P.indices{i}(j))+1;
    P.faceV{P.indices{i}(j)}=[P.faceV{P.indices{i}(j)} i];
  end
end

P.R=R;
end
