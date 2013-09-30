function [opts Jbc] = linode_bc_DFDP(opts, x, p, pars)  %#ok<INUSD>

Jbc = opts.bcond.DP;
