function [opts Jbc] = linode_bc_DFDX(opts, x, p)

Jbc = opts.bcond.Phi;
