% construct the dual to the polyedra of an atlas

function simplexList=constructDualOfAtlas(atlas)

simplexList=[];
chart=atlas.chart{1};
k=chart.k;
offset = 2*k;
n=1;
for i=1:numel(atlas.chart)
    chart=atlas.chart{i};
    P=chart.P;
    ids = [];
    for j=1:numel(P.v)
        ids = [ chart.id ];
        in=1;
        for l=1:numel(P.indices{j})
            face=P.indices{j}(l)-offset;
            if face<=0
                in=0;
            else
                ids = [ ids atlas.oppo(face) ];
            end
            if face>0 && chart.id >= atlas.oppo(face)
                in=0;
            end
        end
        if in==1
            for l=1:k+1
                simplexList(n,l)=ids(l);
            end
            n=n+1;
        end
    end
end

end