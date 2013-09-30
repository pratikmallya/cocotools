%% how to check the derivatives of a function y=f(x,p)

x = [1;1];
p = [0.1;0.5];

% Jacobians
J1 = caricature_DFDX(x,p);
J2 = fdm_ezDFDX('f(x,p)', @caricature, x, p);
spy(abs(J1-J2)>1.0e-4);

% parameter derivatives
J1 = caricature_DFDP(x,p);
J2 = fdm_ezDFDP('f(x,p)', @caricature, x, p, 1:numel(p));
spy(abs(J1-J2)>1.0e-4);

%% derivatives of toolbox functions [d y]=f(o,d,x) using data

% Jacobians
[data J1] = func_DFDX(opts, data, u);
[data J2] = fdm_ezDFDX('f(o,d,x)', opts, data, @func, u);
spy(abs(J1-J2)>1.0e-4);

% parameter derivatives
[data J1] = func_DFDX(opts, data, u);
[data J2] = fdm_ezDFDX('f(o,d,x)', opts, data, @func, u);
spy(abs(J1-J2)>1.0e-4);

%% derivatives of toolbox functions [d y]=f(o,d,x) using data_ptr

% Jacobians
[data_ptr J1] = func_DFDX(opts, data_ptr, u);
[data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @func, u);
spy(abs(J1-J2)>1.0e-4);

% parameter derivatives
[data_ptr J1] = func_DFDX(opts, data_ptr, u);
[data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @func, u);
spy(abs(J1-J2)>1.0e-4);
