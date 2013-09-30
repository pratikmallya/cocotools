function opts = spc_add_TF(opts, prefix, spc, xidx, coll, codim, var_map, varargin)

%% add test functions if required
flag = strcmp(spc.bifurcations, 'on');

switch codim
  case 1
    opts = add_codim1_TF(opts, prefix, spc, flag, xidx, coll, var_map);
    
  otherwise
    error('%s: no test functions defined for codim=%d\n', ...
      mfilename, codim);
end

end

%%
function opts = add_codim1_TF(opts, prefix, spc, flag, xidx, coll, var_map)

if flag
  tfdata.tf_weight   = spc.tf_weight;
  tfdata.mshape      = [coll.x0shape(1) coll.x0shape(1) coll.m0shape(2)];
  tfdata.m0idx       = coll.m0idx;
  tfdata.m1idx       = coll.m1idx;
end
  
tfdata.x0idx       = coll.x0idx(:,1);
tfdata.pidx        = coll.p_idx;
tfdata.tintidx     = coll.tintidx;
tfdata.var_map     = var_map;

tfdata.flag        = flag;

fid  = coco_get_id(prefix, 'codim1_TF');
opts = coco_add_func (opts, fid, @codim1_TF, tfdata, ...
  'regular', {'SN' 'PD' 'TR' 'Re(M1)' 'Im(M1)' 'Re(M2)' 'Im(M2)'}, 'xidx', xidx);

opts = coco_add_event(opts, 'SN', 'SN', 0);
opts = coco_add_event(opts, 'PD', 'PD', 0);
opts = coco_add_event(opts, 'TR', 'TR', 0);

end

%%
function [data y] = codim1_TF(opts, data, xp)
% SPC_TEST_BIFU   Test functions for bifurcations of periodic orbits.

if ~data.flag
%   x0     = xp(data.x0idx);
%   n      = numel(x0);
%   [x1 M] = data.var_map(x0, eye(n,n), xp(data.pidx), sum(xp(data.tintidx))); %#ok<ASGLU>
%   
%   mults = eig(M);
%   [amults idx] = sort(abs(mults-1)); %#ok<ASGLU>
%   mults = [ real(mults(idx(2:end))) imag(mults(idx(2:end))) ]';
%   y = [nan(3,1) ; mults(:)];
  y = nan(7,1);
  return
end

% x0s     = reshape(xp(data.x0idx), data.x0shape);
% M0s     = reshape(xp(data.m0idx), data.mshape);
% M1s     = reshape(xp(data.m1idx), data.mshape); %#ok<NASGU>
% [x1 M2] = data.var_map(x0s(:,1), M0s(:,:,1), xp(data.pidx), sum(xp(data.tintidx))); %#ok<ASGLU>

[data mults] = spc_multipliers(opts, data, xp);
% fprintf('multipliers =');
% fprintf(' % .4e', abs(mults));
% fprintf('\n');
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

mults = [ real(mults) imag(mults) ]';
y = [y ; mults(:)];
end
