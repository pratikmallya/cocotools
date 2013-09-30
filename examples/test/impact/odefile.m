function varargout = odefile(t,y,flag,p,stat)

switch flag
    case ''                                 % Return dy/dt = f(t,y).
        varargout{1} = f(t,y,p,stat);
    case 'events'                           % Return [value,isterminal,direction].
        [varargout{1:3}] = events(t,y,p,stat);
    otherwise
        error(['Unknown flag ''' flag '''.']);
end
%
%% --------------------------------------------------------------------------
%
function dydt = f(t,y,p,stat)

switch stat
    case {1, 2, 3, 4}
        dydt = imp_pslip(y,p);
    case {5, 6, 7, 8}
        dydt = imp_nslip(y,p);
    case {9, 10, 11}
        dydt = imp_stick(y,p);
end
%
%% --------------------------------------------------------------------------
%
function [value,isterminal,direction] = events(t,y,p,stat)

opts=[];

switch stat
    case {1, 5, 9}
        [opts,value] = ev_impact(opts,y,p);
    case {2, 6, 10}
        [opts,value] = ev_phase(opts,y,p);
    case 3
        [opts,value] = ev_stickp(opts,y,p);
    case {4, 8, 11}
        [opts,value] = ev_turning(opts,y,p);
    case 7
        [opts,value] = ev_stickn(opts,y,p);
end
isterminal = [1];
direction = [-1];