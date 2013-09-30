function collargs = imf_create_xode(ode_func)

xode_F(ode_func); % initialise persistent data

collargs = { @xode_F };

% bug: derivatives are not implemented yet
% if ~isempty(ode_func.dfdxhan)
%   collargs = [ collargs 'dfdx' ode_func.dfdxhan ];
% end
% 
% if ~isempty(ode_func.dfdphan)
%   collargs = [ collargs 'dfdp' ode_func.dfdphan ];
% end

end

%%
function y = xode_F(x,p)
persistent ode_F; % bug: this will become part of an additional argument

if nargin==1
  ode_F = x.fhan;
  return
end

y = ode_F(x,p);

end
