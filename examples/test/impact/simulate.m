function seglist = simulate(x,p,signature)

opts=[];
options=odeset('Events','on','AbsTol',1e-8,'RelTol',1e-8,'MaxStep',.01);
tend=100;

for i=1:length(signature)
    [t,x,te,xe,ie]=ode45('odefile',[0 tend],x,options,p,signature(i));
    seglist(i).t0=t;
    seglist(i).x0=x;
    switch signature(i)
        case {1, 2, 3, 4}
            seglist(i).fname = 'pslip';
        case {5, 6, 7, 8}
            seglist(i).fname = 'nslip';
        case {9, 10, 11}
            seglist(i).fname = 'stick';
    end
    switch signature(i)
        case {1, 5, 9}
            seglist(i).event = 'ev_impact';
        case {2, 6, 10}
            seglist(i).event = 'ev_phase';
        case 3
            seglist(i).event = 'ev_stickp';
        case {4, 8, 11}
            seglist(i).event = 'ev_turning';
        case 7
            seglist(i).event = 'ev_stickn';
    end
    switch signature(i)
        case {1, 5, 9}
            seglist(i).dismap = 'dm_impact';
            [opts x]=dm_impact(opts,xe(end,:)',p);
        case {2, 6, 10}
            seglist(i).dismap = 'dm_phase';
            [opts x]=dm_phase(opts,xe(end,:)',p);
        case {3, 4, 7, 8, 11}
            seglist(i).dismap = 'dm_identity';
            [opts x]=dm_identity(opts,xe(end,:)',p);
    end
    seglist(i).NCOL=4;
    seglist(i).NTST=20;
end