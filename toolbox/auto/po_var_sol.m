function [M N x1] = po_var_sol(data, u, varargin)
if nargout==3
  x0    = u(data.x_idx);
  p     = u(data.p_idx);
  T     = u(data.T_idx);
  nx    = numel(x0);
  np    = numel(p);
  x_idx =             1:nx;
  M_idx = nx       + (1:nx*nx);
  N_idx = nx+nx*nx + (1:nx*np);
  M0    = eye(nx);
  N0    = zeros(np,nx);
  v0    = [x0;M0(:);N0(:)];
  fMN   = @(t,v) [
    data.f(v(x_idx),p)
    reshape(data.fx(v(x_idx),p)*reshape(v(M_idx),nx,nx)                      ,nx*nx,1)
    reshape(data.fx(v(x_idx),p)*reshape(v(N_idx),nx,np) + data.fp(v(x_idx),p),nx*np,1)
    ];
  
  [t v] = data.ODEsolver(fMN,[0,T],v0,data.ode_opts); %#ok<ASGLU>
  x1    = v(end,x_idx)';
  M     = reshape(v(end,M_idx)',nx,nx);
  N     = reshape(v(end,N_idx)',nx,np);
  if nargin>=3
    N = N(:,varargin{1});
  end
elseif nargout==2
  x0    = u(data.x_idx);
  p     = u(data.p_idx);
  T     = u(data.T_idx);
  nx    = numel(x0);
  x_idx =             1:nx;
  M_idx = nx       + (1:nx*nx);
  M0    = eye(nx);
  v0    = [x0;M0(:)];
  fMN   = @(t,v) [
    data.f(v(x_idx),p)
    reshape(data.fx(v(x_idx),p)*reshape(v(M_idx),nx,nx),nx*nx,1)
    ];
  
  [t v] = data.ODEsolver(fMN,[0,T],v0,data.ode_opts); %#ok<ASGLU>
  N     = v(end,x_idx)';
  M     = reshape(v(end,M_idx)',nx,nx);
end
end
