%!var_hspo_bddat
function [data res] = var_hspo_bddat(prob, data, command, varargin)

switch command
  case 'init'
    fid   = coco_get_id(data.tbid, 'seg1.coll');
    fdata = coco_get_func_data(prob, fid, 'data');
    edim  = fdata.dim;
    res   = cell(1,edim);
    for i=1:edim
      res{i} = sprintf('L%d',i);
    end
  case 'data'
    chart = varargin{1};
    fid   = coco_get_id(data.tbid, 'seg1.coll');
    fdata = coco_get_func_data(prob, fid, 'data');
    edim  = fdata.dim;
    P     = speye(edim);
    for i=1:data.nsegs
      fid  = coco_get_id(data.tbid, sprintf('seg%d.coll', i));
      [fdata uidx] = coco_get_func_data(prob, fid, 'data', 'uidx');
      u    = chart.x(uidx);
      x    = u(fdata.xbp_idx);
      T    = u(fdata.T_idx);
      p    = u(fdata.p_idx);
      NTST = fdata.coll.NTST;
      NCOL = fdata.coll.NCOL;
      dim  = fdata.dim;
      
      xx = reshape(fdata.W*x, fdata.x_shp);
      pp = repmat(p, fdata.p_rep);
      if isempty(fdata.dfdxhan)
        dfode = coco_ezDFDX('f(x,p)v', fdata.fhan, xx, pp, fdata.mode);
      else
        dfode = fdata.dfdxhan(xx, pp, fdata.mode);
      end
      dfode = sparse(fdata.dxrows, fdata.dxcols, dfode(:));
      dfode = (0.5*T/NTST)*dfode*fdata.W-fdata.Wp;
      [rows cols vals] = find(dfode);
      rows = [rows(:); fdata.off+fdata.Qrows(:)];
      cols = [cols(:); fdata.Qcols(:)];
      vals = [vals(:); fdata.Qvals(:)];
      
      %       J   = sparse(rows, cols, vals);
      %       deye = speye(dim);
      %       row = [.5*deye, sparse(dim, fdata.xbp_idx(end)-2*dim), .5*deye];
      %       rhs = [deye; sparse(fdata.xbp_idx(end)-dim, dim)];
      %       M   = [row; J]\rhs;
      
      J0   = sparse(rows, cols, vals);
      deye = speye(dim);
      B1   = [deye sparse(dim, fdata.xbp_idx(end)-2*dim) deye];
      rhs  = [3*deye; sparse(fdata.xbp_idx(end)-dim, dim)];
      B2   = (0.5/NTST)*fdata.W'*fdata.wts2*fdata.W;
      M0   = repmat(deye, [NTST*(NCOL+1) 1]);%data.M0{i};
      M    = [B1+M0'*B2; J0]\rhs;
      while norm(full(M-M0))>fdata.coll.TOL
        M0 = M;
        M  = [B1+M0'*B2; J0]\rhs;
      end
      data.M0{i} = M;
      M0   = M(1:dim,:);
      M1   = M(end-dim+1:end,:);
      
      x1   = u(fdata.x1_idx);
      fs   = fdata.fhan(x1, p, fdata.mode);
      hx   = data.bc_data.dhdxhan(x1, p, data.bc_data.events{i});
      gx   = data.bc_data.dgdxhan(x1, p, data.bc_data.resets{i});
      P    = gx*(deye-(fs*hx)/(hx*fs))*M1/M0*P;
    end
    d   = eig(P);
    res = cell(1,edim);
    for i=1:edim
      res{i} = d(i);
    end
    
end

end %!end_var_hspo_bddat