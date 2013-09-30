function coverkd_plotCovering(atlas, x,y,z)

for i=1:numel(atlas.chart)
    chart=atlas.chart{i};
    plotPoly(chart, x,y,z);
    c=chart.center;
    text(c(x),c(y),c(z), sprintf('%d',i),'Color','black');
end
end

function []=plotPoly(chart, x,y,z)

color='r';

P=chart.P;
c=chart.center;
TS=chart.TS;

if P.k==2
    t = linspace(0,2*pi,50);
    w= c*ones(1,50) + TS*[cos(t); sin(t)]*chart.R;
    X = w(x,:);
    Y = w(y,:);
    Z = w(z,:);
    line(X,Y,Z,'color', 'm','LineWidth',0.5);
end

for j=1:numel(P.v)
    v=c+TS*P.v{j};
    for k=j+1:numel(P.v)
        inter=intersectSets(P.indices{j},P.indices{k});
        if numel(inter)==1
            w=c+TS*P.v{k};
            X = [v(x) w(x)];
            Y = [v(y) w(y)];
            Z = [v(z) w(z)];
            line(X,Y,Z,'color', color,'LineWidth',2);
        end
    end
end
end
%%
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
