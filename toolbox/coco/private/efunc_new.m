function efunc = efunc_new(efunc)

efunc.funcs = [];

funcarrays = { 'zero' 'embedded' 'regular' 'singular' };
for i = 1:numel(funcarrays)
  efunc.(funcarrays{i}) = [];
end

pararrays = { 'zero_pars' 'inactive_pars' 'active_pars' 'internal_pars' ...
  'regular_pars' 'singular_pars' };
for i = 1:numel(pararrays)
  efunc.(pararrays{i}) = [];
end

efunc.x0          = [];
efunc.tx          = [];
efunc.tp          = [];
efunc.x_dim       =  0;
efunc.p_dim       =  0;
efunc.f_dim       =  0;
efunc.m_dim       =  0;
efunc.x_idx       = [];
efunc.f_idx       = [];
efunc.pidx2midx   = [];
efunc.pidx2fidx   = [];
efunc.idx2par     = {};
efunc.identifyers = {};
efunc.pending     = {};
efunc.cont_pars   = {};
efunc.par_arrays  = struct();

efunc.chart.private.data = {};
efunc.chart.x  = [];
efunc.chart.t  = [];

efunc.F         = @efunc_F;
efunc.FDF       = @efunc_FDF;
efunc.DFDX      = @efunc_DFDX;
efunc.monitor_F = @efunc_monitor_F;
efunc.events_F  = @efunc_events_F;

efunc.close_level = 0;
efunc.add_pending = true;

end
