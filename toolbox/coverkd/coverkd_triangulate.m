function [Tri X] = coverkd_triangulate(atlas)
Tri = constructDualOfAtlas(atlas);

X = [];
for i=1:numel(atlas.chart)
    X = [ X ; atlas.chart{i}.center' ]; %#ok<AGROW>
end

end
