function opts = pocont_add_TF(opts, prefix, pocont, xidx, coll, codim, varargin)

%% add test functions if required
if ~strcmp(pocont.bifurcations, 'on')
  return
end

switch codim
  case 1
    opts = add_codim1_TF(opts, prefix, pocont, xidx, coll);
    
  otherwise
    error('%s: no test functions defined for codim=%d\n', ...
      mfilename, codim);
end

end

%%
function opts = add_codim1_TF(opts, prefix, pocont, xidx, coll)

tfdata.tf_weight   = pocont.tf_weight;
tfdata.mshape      = [coll.x0shape(1) coll.x0shape(1) coll.m0shape(2)];
tfdata.m0idx       = coll.m0idx;
tfdata.m1idx       = coll.m1idx;

fid  = coco_get_id(prefix, 'codim1_TF');
opts = coco_add_func (opts, fid, @codim1_TF, tfdata, ...
  'regular', {'SN' 'PD' 'TR'}, 'xidx', xidx(coll.x_idx));

opts = coco_add_event(opts, 'SN', 'SN', 0);
opts = coco_add_event(opts, 'PD', 'PD', 0);
opts = coco_add_event(opts, 'TR', 'TR', 0);

end

%%
function [data y] = codim1_TF(opts, data, xp)
% POCONT_TEST_BIFU   Test functions for bifurcations of periodic orbits.

[data mults] = pocont_multipliers(opts, data, xp);
%fprintf('multipliers = % .4e % .4e\n', mults(1), mults(2));
% remove trivial and fixed multipliers
% mults     = mults(numel(data.mignore_idx)+2:end);
mults     = mults(2:end);

n         = numel(mults);
tf_weight = data.tf_weight;

if n>=1
  tf     = mults-1;                     % limit points
  tf     = tf_weight*tf./(1+abs(tf));
  y(1,:) = real(prod(tf));
else
  y(1,:) = ones(1,size(xp,2));
end

if n>1
	A    = repmat(1:n, n, 1);
	idx1 = A(tril(A,-1)~=0);
	A    = A';
	idx2 = A(tril(A,-1)~=0);
	
  tf     = mults+1;                     % period-doubling points
  tf     = tf_weight*tf./(1+abs(tf));
	y(2,:) = real(prod(tf));
  
  tf     = mults(idx1).*mults(idx2)-1;  % Neimark-Sacker points
  tf     = tf_weight*tf./(1+abs(tf));
	y(3,:) = real(prod(tf));
else
	% no period-doubling and Neimark-Sacker points
	y(2:3,:) = ones(2,size(xp,2));
end

end
