function opts = linode_bc_init(opts, x, p) %#ok<INUSD>

x0idx = reshape(opts.coll.x0idx,   opts.coll.x0shape  );
x1idx = reshape(opts.coll.x1idx,   opts.coll.x1shape  );
x1idx = x1idx(:,1:end-1);
Tidx  = reshape(opts.coll.tintidx, opts.coll.tintshape);

segnum = size(x0idx, 2);

nrows = 4*segnum;
rows  = [1:3*segnum 3+(1:3*(segnum-1)) 3*segnum+(1:segnum)]';
cols  = [x0idx(:) ; x1idx(:) ; Tidx(:)];

vals           = [ones(1,3*segnum) -ones(1,3*(segnum-1)) ones(1,segnum)];
opts.bcond.Phi = sparse(rows, cols, vals, nrows, opts.coll.fullsize);
opts.bcond.DP  = sparse(nrows, 1);

vals           = [zeros(3*segnum,1) ; x(opts.coll.tintidx)];
opts.bcond.b   = sparse(1:nrows, 1, vals, nrows, 1);
