function [coll J] = coll_DFDP(opts, coll, x, p, pars) %#ok<INUSL>
%Compute parameter derivatives DCOLL_F/DP(PARS) at (X,P).

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of derivative
% [opts J] = coco_num_DFDP(opts, opts.func.F, x, p, pars);

%% initialisations
%  map base points to collocation points
xx = reshape(coll.W * x, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T from x
T  = x(coll.tintidx);

%  expand T and ka to fit size of xx
T    = reshape(T(coll.tintxidx), [coll.xshape 1]);
T    = repmat(T, [1 1 length(pars)]);
ka   = reshape(coll.ka(coll.kaxidx), [coll.xshape 1]);
ka   = repmat(ka, [1 1 length(pars)]);

%% compute derivative of collocation condition
%  preallocate array for derivatives
dfode = zeros([coll.xshape length(pars)]);

%  compute derivatives of each vector field
%  Note: we should get rid of the loop over j!
for rhsnum=1:length(coll.rhss)
  % for j=1:length(pars)
  %   % Note: this needs to be modified to perform tests as in
  %   % exacont/private/func_DFDP
  %   dfode(:, coll.rhss(rhsnum).xcolidx, j) = ...
  %     coco_num_DFDPv(coll.rhss(rhsnum).fhan, xx(:,coll.rhss(rhsnum).xcolidx), ...
  %     pp(:,coll.rhss(rhsnum).xcolidx), pars(j));
  % end
  % %  evaluate derivative of collocation condition
  % dfode(:,:,j) = T .* ka .* dfode(:,:,j);
    
  xcolidx = coll.rhss(rhsnum).xcolidx;
  dfdphan = coll.rhss(rhsnum).dfdphan;
  
  if isempty(dfdphan)
    fhan = coll.rhss(rhsnum).fhan;
    if coll.rhss(rhsnum).vectorised
      for j=1:length(pars)
        dfode(:,xcolidx,j) = coco_num_DFDPv(fhan, xx(:,xcolidx), ...
          pp(:,xcolidx), pars(j));
      end
    else
      for j=1:length(pars)
        dfode(:,xcolidx,j) = coco_num_DFDP (fhan, xx(:,xcolidx), ...
          pp(:,xcolidx), pars(j));
      end
    end
  else
    % fhan = coll.rhss(rhsnum).fhan;
    % for j=1:length(pars)
    %   dfode(:,xcolidx,j) = coco_num_DFDPv(fhan, xx(:,xcolidx), ...
    %     pp(:,xcolidx), pars(j));
    % end
    dfode = reshape(dfdphan(xx(:,xcolidx), pp(:,xcolidx)), size(dfode));
  end
end
dfode = T .* ka .* dfode;

%  reshape into a matrix with length(pars) columns
dfode = reshape(dfode, [prod(coll.xshape) length(pars)]);

%% derivative of continuity condition
dfcont = sparse( size(coll.Phi,1), length(pars) );

%% combine derivatives of all conditions
%  into one large vector
%  Note: this will become re-ordered in the future to reduce band width.
J = [ dfode ; dfcont ];
