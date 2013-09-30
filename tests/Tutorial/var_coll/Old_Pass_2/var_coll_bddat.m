%!var_bddat
function [data res] = var_coll_bddat(prob, data, command, varargin)

switch command
  case 'init'
    dim = data.dim;
    res = cell(1,dim);
    for i=1:dim
      res{i} = sprintf('L%d',i);
    end
    res = [res, 'cond'];
  case 'data'
    chart = varargin{1};
    uidx  = coco_get_func_data(prob, data.tbid, 'uidx');
    u     = chart.x(uidx);
    x     = u(data.xbp_idx);
    T     = u(data.T_idx);
    p     = u(data.p_idx);
    NTST  = data.coll.NTST;
    dim   = data.dim;
    
    xx = reshape(data.W*x, data.x_shp);
    pp = repmat(p, data.p_rep);
    if isempty(data.dfdxhan)
      dfode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp, data.mode);
    else
      dfode = data.dfdxhan(xx, pp, data.mode);
    end
    dfode = sparse(data.dxrows, data.dxcols, dfode(:));
    dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;
    [rows cols vals] = find(dfode);
    rows = [rows(:); data.off+data.Qrows(:)];
    cols = [cols(:); data.Qcols(:)];
    vals = [vals(:); data.Qvals(:)];
    
    J0   = sparse(rows, cols, vals);
    deye = speye(dim);
    B1   = [deye sparse(dim, data.xbp_idx(end)-2*dim) deye];
    rhs  = [3*deye; sparse(data.xbp_idx(end)-dim, dim)];
    B2   = (0.5/NTST)*data.W'*data.wts2*data.W;
    M0   = data.M0;
    M    = [B1+M0'*B2; J0]\rhs;
    while norm(full(M-M0))>data.coll.TOL
      M0 = M;
      J  = [B1+M0'*B2; J0];
      M  = J\rhs;
    end
    data.M0 = M;
    M0  = full(M(1:dim,:));
    M1  = full(M(end-dim+1:end,:));
    d   = eig(M1,M0);
    res = cell(1,dim);
    for i=1:dim
      res{i} = d(i);
    end
    res = [res, condest(J)];
    
end

end %!end_var_bddat