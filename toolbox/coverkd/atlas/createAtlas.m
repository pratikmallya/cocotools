function atlas = createAtlas()
% Constructs an empty atlas

atlas.nrm          = {};      % List of half space normals (k-space)
atlas.onrm         = [];      % List of half space origins x.nrm=onrm
atlas.oppo         = [];      % Chart on opposite side of each face.
atlas.boundaryList = [];      % List of charts that might be on the boundary
atlas.boundaryR    = [];      % Radii of boundary charts
atlas.boundingBox  = [];      % The hierarchical bounding box
atlas.chart        = {};      % List of the charts in this atlas

end
