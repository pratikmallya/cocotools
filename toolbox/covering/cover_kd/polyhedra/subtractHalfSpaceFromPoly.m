% Removes the halfspace x.nrm-on>0 from a polyhedron

%     struct MFPolytopeSt{
%                     int k;                /* Dimension of the vertices
%                     int n;                /* Number of vertices
%                     double R;             /* Radius
%                     int m;                /* Space for vertices
%                     double *v;            /* vertices
%                     int *nIndices;        /* Number of indices for each vertex
%                     int *mIndices;        /* Space for indices for each vertex
%                     int **indices;        /* Indices of each vertex
%                     int *mark;            /* Mark on each vertex
%
%                     int nFaces;
%                     int mFaces;
%                     int *face;          /* Index of face
%                     int *nFaceV;        /* Number of vertices on each face
%                     MFKVector *faceN;   /* Normal of face
%                     double *faceO;      /* Origin of face
%                    };

function P=subtractHalfSpaceFromPoly(P,index,nrm,on)
d=zeros(1,P.n);

t=max(abs(nrm));
t=max([t,abs(on)]);

% Mark vertices as to side of the half space

for i=1:P.n
    d(i)=(P.v{i}'*nrm-on)/t;
    if abs(d(i))<eps
        P.nIndices(i)=P.nIndices(i)+1;
        P.indices{i}=[ P.indices{i} index ];
    end
end

% Loop over edges and insert vertex where it the edge crosses the half space

nold=P.n;
for i=1:nold
    n1=P.nIndices(i);
    for j=i+1:nold
        
        %  This number should be relative to the longest edge of the
        %  polytope
        if (d(i)<0 && d(j)>0) || (d(i)>0 && d(j)<0)
            if abs(d(i))>eps && abs(d(j))>eps
                n2=P.nIndices(j);
                m=max(n1,n2);
                
                if m>0
                    inter=intersectSets(P.indices{i},P.indices{j});
                    n=numel(inter);
                else
                    n=0;
                end
                
                if n >= P.k-1
                    newV=P.n+1;
                    t=-d(i)/(d(j)-d(i));
                    
                    P.v{newV}=(1-t)*P.v{i}+t*P.v{j};
                    P.nIndices(newV)=n+1;
                    P.mark(newV)=0;
                    P.indices{newV}=[ inter index ];
                    d(newV)=-100.;
                    P.n=P.n+1;
                end
            end
        end
        
    end
end

% Remove wrong sided vertices

i=1;
while i<=P.n
    
    %  if d(i)>0
    %   if i<P.n-1
    %    P.v{i}=P.v{P.n-1};
    %    P.indices(i)=P.indices(P.n-1);
    %    P.nIndices(i)=P.nIndices(P.n-1);
    %    P.mIndices(i)=P.mIndices(P.n-1);
    %    P.mark(i)=P.mark(P.n-1);
    %    d(i)=d(P.n-1);
    %   end
    %   P.nIndices(P.n-1)=0;
    %   P.mIndices(P.n-1)=0;
    %   P.mark(P.n-1)=0;
    %   d(P.n-1)=0.;
    %   P.n=P.n-1;
    %   i=i-1;
    
    if d(i)>0
        P.v(i)=[];
        P.nIndices(i)=[];
        P.indices(i)=[];
        P.mark(i)=[];
        d(i)=[];
        P.n=P.n-1;
    else
        if d(i)==0
            P.indices{i}=sort([P.indices{i},index]);
        end
        i=i+1;
    end
end

%  Add new face to list.

P.nFaces=P.nFaces+1;
P.face(P.nFaces)=index;
P.faceN{P.nFaces}=nrm;
P.faceO(P.nFaces)=on;
P.nFaceV(P.nFaces)=0;

%  Remove redundant faces.

P.nFaceV=zeros(1,P.nFaces);
P.faceV=cell(1,P.nFaces);

for i=1:P.n
    for j=1:P.nIndices(i)
        index=P.indices{i}(j);
        for l=1:P.nFaces
            if P.face(l)==index
                P.nFaceV(l)=P.nFaceV(l)+1;
                P.faceV{l}=[P.faceV{l} i];
            end
        end
    end
end

i=1;
while i<=P.nFaces
    
    if P.nFaceV(i)<P.k
        for j=1:P.n
            jj=1;
            while jj<=P.nIndices(j)
                if P.indices{j}(jj)==P.face(i)
                    P.indices{j}(jj)=[];
                    P.nIndices(j)=P.nIndices(j)-1;
                else
                    jj=jj+1;
                end
            end
        end
        
        P.face(i)=[];
        P.nFaceV(i)=[];
        P.faceN(i)=[];
        P.faceO(i)=[];
        
        P.nFaces=P.nFaces-1;
    else
        i=i+1;
    end
end
end

function C=intersectSets(A,B)

%  Returns the intersection of two SORTED index sets

nA=numel(A);
nB=numel(B);
C=[];

iA=1;
iB=1;
while iA<=nA&&iB<=nB
    if A(iA)==B(iB)
        C = [ C , A(iA) ]; %#ok<AGROW>
        iA=iA+1;
        iB=iB+1;
    elseif A(iA)<B(iB)
        iA=iA+1;
    else
        iB=iB+1;
    end
end
end
