switchpath('old')
fdata.dim = 42;
fdata.u_idx = 1:2*fdata.dim+4;
fdata.p_idx = (2*fdata.dim+5):(2*fdata.dim+10);
fdata.A = spdiags([ones(2*fdata.dim,1) zeros(2*fdata.dim,1) ...
    -2*ones(2*fdata.dim,1) zeros(2*fdata.dim,1) ...
    ones(2*fdata.dim,1)], [0 1 2 3 4], 2*fdata.dim, 2*fdata.dim+4);
fdata.B = 1/12 * spdiags([ones(2*fdata.dim,1) zeros(2*fdata.dim,1) ...
    10*ones(2*fdata.dim,1) zeros(2*fdata.dim,1) ...
    ones(2*fdata.dim,1)],[0 1 2 3 4], 2*fdata.dim, 2*fdata.dim+4);
fdata.h2 = 1/(fdata.dim+1)^2;

fdata.f = @brusselator;
fdata.f_DX = @brusselator_DFDX;
fdata.f_DP = @brusselator_DFDP;
fdata.dfdx = @finitediff_DFDX;

p0 = [0.0016; 0.008; 2; 0; 0.5; 4.6];
u0 = repmat([p0(3) p0(6)/p0(3)], [fdata.dim+2, 1]);
u0 = reshape(u0', [2*fdata.dim+4, 1]);

opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx, {'DX', 'DY', 'A0', 'L', 'DA', 'B'});

fdata_ptr = coco_ptr(fdata);
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata_ptr, 'bddat');
opts = coco_add_func(opts, 'finitediff_fold1', @finitediff_fold1, fdata, 'singular', 'fold');
opts = coco_add_event(opts, 'LP', 'fold', 0);
opts = coco_set(opts, 'cont', 'ItMX', 2000);
bd = coco(opts, 'run', [], {'L' 'fold'}, [0, .3]);

L   = coco_bd_col(bd, 'L');
A0  = coco_bd_col(bd, 'A0');
nU  = coco_bd_col(bd, 'norm(U)');
idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE')));

figure(1)
clf
hold on
plot3(L,nU,A0,'r')
hold on
plot3(L(idx),nU(idx),A0(idx),'rs')
hold off


fdata.c = (1:2*fdata.dim+4)'/sqrt(sum((1:2*fdata.dim+4).^2));
fdata.b = fdata.c;
fdata_ptr = coco_ptr(fdata);

opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx, {'DX', 'DY', 'A0', 'L', 'DA', 'B'});
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata_ptr, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 2000);
opts = coco_add_func(opts, 'finitediff_fold2', @finitediff_fold2, fdata_ptr, 'active', 'fold');
opts = coco_add_event(opts, 'LP', 'fold', 0);
opts = coco_add_slot(opts, 'update', @update1, fdata_ptr, 'covering_update');
bd = coco(opts, 'run', [], {'L' 'fold'}, [0, .3]);

L   = coco_bd_col(bd, 'L');
A0  = coco_bd_col(bd, 'A0');
nU  = coco_bd_col(bd, 'norm(U)');
idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE')));

figure(1)
hold on
plot3(L,nU,A0,'b')
hold on
plot3(L(idx),nU(idx),A0(idx),'bo')
hold off


labs = coco_bd_col(bd, 'LAB');
[tempdata sol] = coco_read_solution('', 'run', labs{idx(1)});

p0 = sol.x(fdata.p_idx);
u0 = sol.x(fdata.u_idx);

[fdata JJ] = fdata.dfdx(opts, fdata, [u0; p0]);

[v,d] = eig(full(JJ(1:2*fdata.dim+4,1:2*fdata.dim+4)));
[~,k] = min(abs(diag(d)));
fdata.c = v(:,k);
fdata.c = fdata.c/norm(fdata.c,2);

[v,d] = eig(full(JJ(1:2*fdata.dim+4,1:2*fdata.dim+4)'));
[l,k] = min(abs(diag(d)));
if v(1,k)>0
    fdata.b = v(:,k);
else
    fdata.b = -v(:,k);
end
fdata.b = fdata.b/norm(fdata.b,2);

fdata_ptr = coco_ptr(fdata);

opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx([1:2,4:6]), {'DX', 'DY', 'L', 'DA', 'B'});
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata_ptr, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 100);
opts = coco_add_func(opts, 'finitediff_fold2', @finitediff_fold2, fdata_ptr, 'zero');
opts = coco_add_slot(opts, 'update', @update2, fdata_ptr, 'covering_update');
bd = coco(opts, 'run', [], 'L', [0, .3]);

L   = coco_bd_col(bd, 'L');
A0  = coco_bd_col(bd, 'A0');
nU  = coco_bd_col(bd, 'norm(U)');

figure(1)
hold on
plot3(L,nU,A0,'k')
hold off


[fdata JJ] = fdata.dfdx(opts, fdata, [u0; p0]);

[v,d] = eig(full(JJ(1:2*fdata.dim+4,1:2*fdata.dim+4)));
[~,k] = min(abs(diag(d)));
sigma0 = v(:,k)/norm(v(:,k),2);
eigvl0 = 0;
fdata.sigma_idx = (2*fdata.dim+11:4*fdata.dim+14);
fdata.eigvl_idx = 4*fdata.dim+15;

opts = coco_add_func('finitediff', @finitediff, fdata, 'zero', 'x0', [u0; p0]);
opts = coco_add_parameters(opts, '', fdata.p_idx([1:2,4:6]), {'DX', 'DY', 'L', 'DA', 'B'});
opts = coco_add_slot(opts, 'bd_cb', @bddat, fdata_ptr, 'bddat');
opts = coco_set(opts, 'cont', 'ItMX', 100);
opts = coco_add_func(opts, 'finitediff_fold3', @finitediff_fold3, fdata, ...
    'zero', 'x0', [sigma0; eigvl0], ...
    'xidx', [fdata.u_idx fdata.p_idx fdata.sigma_idx fdata.eigvl_idx]);
opts = coco_add_func(opts, 'eigvl', @eigvl, [], 'inactive', 'eigvl', 'xidx', fdata.eigvl_idx);
bd = coco(opts, 'run', [], {'L'}, [0, .3]);

L   = coco_bd_col(bd, 'L');
A0  = coco_bd_col(bd, 'A0');
nU  = coco_bd_col(bd, 'norm(U)');

figure(1)
hold on
plot3(L,nU,A0,'m')
hold off
