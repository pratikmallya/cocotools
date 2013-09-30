function data = hspo_init_data(data, fhan, dfdxhan, dfdphan, ...
  modes, events, resets, x0, p0)

data.hhan    = fhan{2};
data.dhdxhan = dfdxhan{2};
data.dhdphan = dfdphan{2};
data.ghan    = fhan{3};
data.dgdxhan = dfdxhan{3};
data.dgdphan = dfdphan{3};
data.modes   = modes;
data.events  = events;
data.resets  = resets;

nsegs       = numel(events);
data.nsegs  = nsegs;
data.x0_idx = cell(1,nsegs);
data.x1_idx = cell(1,nsegs);
cdim        = 0;
dim         = zeros(1,nsegs);
data.dim    = dim;
for i=1:nsegs
  dim(i)         = size(x0{i},2);
  data.dim(i)    = dim(i);
  data.x0_idx{i} = cdim+(1:dim(i))';
  data.x1_idx{i} = cdim+(1:dim(i))';
  cdim           = cdim+dim(i);
end
data.cdim = cdim;
rows = [];
cols = [];
off  = 0;
pdim = numel(p0);
data.pdim = pdim;
for i=1:nsegs
  rows = [rows; repmat(off+1, [dim(i)+pdim 1])];
  rows = [rows; repmat(off+1+(1:dim(mod(i,data.nsegs)+1))', ...
    [1+dim(i)+pdim 1])];
  cols = [cols; nsegs+cdim+data.x1_idx{i}; nsegs+2*cdim+(1:pdim)'];
  c2   = repmat(nsegs+cdim+data.x1_idx{i}', ...
    [dim(mod(i,data.nsegs)+1) 1]);
  c3   = repmat(nsegs+2*cdim+(1:pdim), [dim(mod(i,data.nsegs)+1) 1]);
  cols = [cols; nsegs+data.x0_idx{mod(i,data.nsegs)+1}; c2(:); c3(:)];
  off  = off+dim(mod(i,data.nsegs)+1)+1;
end
data.rows = rows;
data.cols = cols;

I            = triu(true(dim(1)),1);
A            = repmat((1:dim(1))', 1, dim(1));
data.la_idx1 = A(I);
A            = A';
data.la_idx2 = A(I);

end