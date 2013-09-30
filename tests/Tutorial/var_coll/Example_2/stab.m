function evs = stab(nseg, rrun, rlab)
% function computes Floquet multipliers for periodic multi-segment
% trajectory obtained during continuation.

P = eye(2);
for i=1:nseg
    [data chart] = coco_read_solution(sprintf('hspo.seg%d.coll',i), rrun, rlab);
    x1 = chart.x(data.x1_idx);
    p  = chart.x(data.p_idx);
    fs = pwlin(x1,p,data.model);
    J  = pwlin_bc_DFDX(x1,x1,p,data.model);
    hx = J(data.dim+1,data.dim+1:data.dim+2);
    gx = -J(1:data.dim,data.dim+1:data.dim+2);
    
    varopts = var_sol2var(sprintf('hspo.seg%d', i), rrun, rlab);
    varopts = coco_set(varopts, 'cont', 'ItMX', 2000);
    bd      = coco(varopts, sprintf('var%d', i), [], 1, 'beta', [0 1]);
    
    
    labs    = coco_bd_labs(bd, 'EP');
    [data sol] = coco_read_solution(sprintf('hspo.seg%d.var',i), sprintf('var%d', i), labs(end));
    mat     = reshape(sol.x(1:numel(data.x_idx)),[numel(data.x_idx)/data.dim data.dim]);
    m0 = mat(1:data.dim,1:data.dim);
    m1 = mat(end-data.dim+1:end,1:data.dim);
    
    P = (gx*(eye(2)-(fs * hx)/(hx*fs))*m1/m0)*P;
end

evs = eig(P);

end