function opts = pocont_add_TR_funcs(opts, prefix, pocont, xidx, coll)

%% compute initial eigenvector
fid                  = coco_get_id(prefix, 'coll');
x0                   = coco_get_func_data(opts, fid, 'x0');
tfdata.tf_weight     = pocont.tf_weight;
tfdata.mshape        = [coll.x0shape(1) coll.x0shape(1) coll.m0shape(2)];
tfdata.m0idx         = coll.m0idx;
tfdata.m1idx         = coll.m1idx;
[tfdata evecs evals] = pocont_multipliers(opts, tfdata, x0); %#ok<ASGLU>
evals                = diag(evals);
evals                = evals(2:end);
[pdev pdidx]         = min(abs(evals)-1); %#ok<ASGLU>
evec                 = rotate_evec(opts, evecs(:,pdidx+1));
x0                   = [real(evec) ; imag(evec) ; 1 ; angle(evals(pdidx)) ];

%% create NS function data
data.m0idx     =                        1:numel(coll.m0idx);
data.m1idx     = data.m0idx(end)     + (1:numel(coll.m1idx));
data.evecreidx = data.m1idx(end)     + (1:coll.dim);
data.evecimidx = data.evecreidx(end) + (1:coll.dim);
data.evalidx   = data.evecimidx(end) +  [1 2];
data.mshape    = coll.mshape([1 3]);

%% add eigenvalue equations
fid         = coco_get_id(prefix, 'TR_evcnd');
[opts xidx] = coco_add_func(opts, fid, @pocont_NS_F, @pocont_NS_DFDX, ...
  data, 'zero', 'xidx', xidx([coll.m0idx ; coll.m1idx]), 'x0', x0);

%% add period-doubling test function for parameter exchange
fid  = coco_get_id(prefix, 'TF_TR');
opts = coco_add_func(opts, fid, @func_NS, @func_DNSDX, ...
  data, 'internal', fid, 'xidx', xidx(data.evalidx(1)));
opts = coco_set_parival(opts, fid, 0);
end

%%
function z = rotate_evec(opts, xx)
x  = real(xx);
y  = imag(xx);

if abs(x'*y)<10*opts.nwtn.TOL
  z = xx;
  return
end

ga = (y'*y-x'*x)/(x'*y);
if ga>0
  p0 = acot(1+ga);
  p1 = pi/4;
else
  p0 = pi/4;
  p1 = atan(1-ga);
end

phi = (p0+p1)/2;
while abs(p1-p0)>opts.nwtn.TOL
  if (cot(p0)-tan(p0)-ga)*(cot(phi)-tan(phi)-ga)<0
    p1 = phi;
  else
    p0 = phi;
  end
  phi = (p0+p1)/2;
end
z = (cos(phi)+1i*sin(phi))*xx;
end

%%
function [data f] = pocont_NS_F(opts, data, xp) %#ok<INUSL>

M0  = reshape(xp(data.m0idx), data.mshape);
M1  = reshape(xp(data.m1idx), data.mshape);
xx  = xp(data.evecreidx);
yy  = xp(data.evecimidx);
r   = xp(data.evalidx(1));
phi = xp(data.evalidx(2));

a = r*cos(phi);
b = r*sin(phi);

f = [ ...
  (M1-a*M0)*xx + b*M0*yy
  (M1-a*M0)*yy - b*M0*xx
  xx'*xx + yy'*yy - 1
  xx'*yy
  ];
end

%%
function [data J] = pocont_NS_DFDX(opts, data, xp) %#ok<INUSL>

M0    = reshape(xp(data.m0idx), data.mshape);
M0idx = reshape(data.m0idx,     data.mshape);
M1    = reshape(xp(data.m1idx), data.mshape);
M1idx = reshape(data.m1idx,     data.mshape);

xx    = repmat(xp(data.evecreidx)', data.mshape(1), 1);
xxidx = repmat(data.evecreidx,      data.mshape(1), 1);
yy    = repmat(xp(data.evecimidx)', data.mshape(1), 1);
yyidx = repmat(data.evecimidx,      data.mshape(1), 1);

r      = xp(data.evalidx(1));
ridx   = data.evalidx(ones(data.mshape(1),1))';
phi    = xp(data.evalidx(2));
phiidx = data.evalidx(2*ones(data.mshape(1),1))';
a      = r*cos(phi);
b      = r*sin(phi);

rowidx = repmat((1:data.mshape(1))', 1, data.mshape(2));

% derivative of (M1-r*cos(phi)*M0)*xx
rows = [ rowidx  rowidx rowidx  ];
cols = [ M1idx   M0idx  xxidx   ];
vals = [ xx     -a*xx   M1-a*M0 ];

rows = [rows  rowidx(:,1)          rowidx(:,1)            ];
cols = [cols  ridx                 phiidx                 ];
vals = [vals -cos(phi)*M0*xx(1,:)' r*sin(phi)*M0*xx(1,:)' ];

% derivative of r*sin(phi)*M0*yy
rows = [rows rowidx rowidx rowidx(:,1)          rowidx(:,1)            ];
cols = [cols M0idx  yyidx  ridx                 phiidx                 ];
vals = [vals b*yy   b*M0   sin(phi)*M0*yy(1,:)' r*cos(phi)*M0*yy(1,:)' ];

% derivative of (M1-r*cos(phi)*M0)*yy
rowidx = rowidx + numel(data.evecreidx);

rows = [rows  rowidx  rowidx rowidx  ];
cols = [cols  M1idx   M0idx  yyidx   ];
vals = [vals  yy     -a*yy   M1-a*M0 ];

rows = [rows  rowidx(:,1)          rowidx(:,1)            ];
cols = [cols  ridx                 phiidx                 ];
vals = [vals -cos(phi)*M0*yy(1,:)' r*sin(phi)*M0*yy(1,:)' ];

% derivative of - r*sin(phi)*M0*xx
rows = [rows  rowidx  rowidx  rowidx(:,1)           rowidx(:,1)            ];
cols = [cols  M0idx   xxidx   ridx                  phiidx                 ];
vals = [vals -b*xx   -b*M0   -sin(phi)*M0*xx(1,:)' -r*cos(phi)*M0*xx(1,:)' ];

% derivative of xx'*xx + yy'*yy - 1
r    = numel(data.evecreidx);
rows = [ rows(:) ; (2*r+1)*ones(r,1)      ; (2*r+1)*ones(r,1)      ];
cols = [ cols(:) ; data.evecreidx(:)      ; data.evecimidx(:)      ];
vals = [ vals(:) ; 2.0*xp(data.evecreidx) ; 2.0*xp(data.evecimidx) ];

% derivative of xx'*yy
rows = [ rows(:) ; (2*r+2)*ones(r,1)  ; (2*r+2)*ones(r,1)  ];
cols = [ cols(:) ; data.evecreidx(:)  ; data.evecimidx(:)  ];
vals = [ vals(:) ; xp(data.evecimidx) ; xp(data.evecreidx) ];

J = sparse(rows, cols, vals, 2*r+2, numel(xp));
end

%%
function [data g] = func_NS(opts, data, xp) %#ok<INUSL>
g = xp - 1;
end

%%
function [data J] = func_DNSDX(opts, data, xp) %#ok<INUSD,INUSL>
J = speye(1);
end
