function J = hspo_bc_DFDX(data, T, x0, x1, p)

cdim  = data.cdim;
pdim  = data.pdim;
nsegs = data.nsegs;
vals  = [];
for i=1:nsegs
  if ~isempty(data.dhdxhan)
    dhdx = data.dhdxhan(x1(data.x1_idx{i}), p, data.events{i});
  else
    dhdx = coco_ezDFDX('f(x,p)v', data.hhan, x1(data.x1_idx{i}), ...
      p, data.events{i});
  end
  if ~isempty(data.dhdphan)
    dhdp = data.dhdphan(x1(data.x1_idx{i}), p, data.events{i});
  else
    dhdp = coco_ezDFDP('f(x,p)v', data.hhan, x1(data.x1_idx{i}), ...
      p, data.events{i});
  end
  if ~isempty(data.dgdxhan)
    dgdx = data.dgdxhan(x1(data.x1_idx{i}), p, data.resets{i});
  else
    dgdx = coco_ezDFDX('f(x,p)v', data.ghan, x1(data.x1_idx{i}), ...
      p, data.resets{i});
  end
  if ~isempty(data.dgdphan)
    dgdp = data.dgdphan(x1(data.x1_idx{i}), p, data.resets{i});
  else
    dgdp = coco_ezDFDP('f(x,p)v', data.ghan, x1(data.x1_idx{i}), ...
      p, data.resets{i});
  end
  vals = [vals; dhdx(:); dhdp(:); ...
    ones(data.dim(mod(i,data.nsegs)+1),1); -dgdx(:); -dgdp(:)];
end
J = sparse(data.rows, data.cols, vals, nsegs+cdim, nsegs+2*cdim+pdim);

end