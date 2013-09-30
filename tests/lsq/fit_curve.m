function [data C t Res3 Res2 Res ZZ1 ZZ2 ZZ3] = fit_curve(opts, data, t0, TOL) %#ok<INUSL>

al = linspace(0,2*pi, 1000);
tt = [cos(al);-sin(al)];
rs = [];
for t=tt
  [data Res Res2 A C YY ZZ2 o2] = fit3([], data, t); %#ok<ASGLU,NASGU>
  rs = [rs Res]; %#ok<AGROW>
end
plot(al,sqrt(rs));

% simple steepest gradient method for non-linear fit
[data DX] = fdm_ezDFDX('f(o,d,x)', [], data, @fit3, t0);
[data ResOld Res2Old A C YY ZZ2 o2] = fit3([], data, t0); %#ok<NASGU>
t0        = t0/norm(t0);
t         = t0;
ga        = 1;
while norm(DX)>TOL^2
  ga = ga*2;
  % rdx = (norm(Res)+norm(DX))*randn(numel(DX),1);
  rdx = zeros(numel(DX),1);
  t  = t0-ga*DX' - rdx;
  t  = t/norm(t);
  while ga>1.0e-4
    [data Res Res2 A C YY ZZ2 o2] = fit3([], data, t); %#ok<NASGU>
    if Res<=ResOld
      break;
    else
      ga = ga/2;
    end
    t  = t0-ga*DX' - rdx;
    t  = t/norm(t);
  end
  t0      = t;
  Res2Old = Res2;
  ResOld  = Res;
  [data DX] = fdm_ezDFDX('f(o,d,x)', [], data, @fit3, t);
  fprintf('ga = % .2e, ||dx|| = % .2e, Res = % .2e, t = [% .2e % .2e]\n', ...
    ga, norm(DX), sqrt(Res), t(1), t(2));

  [data Res Res2 A C YY ZZ2 o2] = fit3([], data, t); %#ok<NASGU>
  ZZ1  = (A(:,1:2)*C(1:2,:))';
  ZZ3  = (A*C)';
  plot(ZZ1(1,:), ZZ1(2,:), 'k.-', YY(1,:), YY(2,:), 'r.', ...
    ZZ3(1,:), ZZ3(2,:), 'g-', ZZ2(1,:), ZZ2(2,:), 'b-', ...
    'LineWidth', 2.0);
  axis equal
  grid on
  drawnow
end
[data Res Res2 A C YY ZZ2 o2] = fit3([], data, t);

ZZ1  = (A(:,1:2)*C(1:2,:))';

ZZ3  = (A*C)';
Res3 = YY-ZZ3;
Res3 = sqrt(sum(sum(Res3.^2,1))/(numel(o2)-1)); % standard deviation for sample

end

function [data Res Res2 A C YY ZZ2 o2] = fit3(opts, data, t) %#ok<INUSL>
o1 = ones(1,size(data.y,1)); %#ok<NASGU>
o2 = ones(1,size(data.y,2));
Y0 = mean(data.y,2);
Y0 = Y0(:,o2);
XX = data.y - Y0;

t        = t/norm(t);
[xx idx] = sort(XX'*t);
YY = data.y(:,idx);
xx = xx-xx(1);
xx = xx/(xx(end)-xx(1));
xx = 2*xx-1;

% use Legendre polynomials for fit -> A closer to orthogonal
% A  = [ ...
%   sqrt(1/2)*o2' ...
%   sqrt(3/2)*xx ...
%   sqrt(5/8)*(3*xx.^2-1) ...
%   sqrt(7/8)*(5*xx.^3-3*xx) ...
%   ];

% % compute orthogonal polynomials
% h  = xx(2:end)-xx(1:end-1);
% hh = 0.5*([h;0]+[0;h]);
% p0 = sqrt(1/2)*o2';
% 
% b  = - xx' * (p0.*hh);
% A  =   o2  * (p0.*hh);
% a  = A \ b;
% p1 = xx + a*o2';
% n1 = p1' * (p1.*hh);
% p1 = p1/sqrt(n1);
% 
% b  = - [ xx.^2' * (p0.*hh) ; xx.^2' * (p1.*hh) ];
% A  =   [ xx'*(p0.*hh) o2*(p0.*hh)
%   xx'*(p1.*hh) o2*(p1.*hh) ];
% a  = A \ b;
% p2 = xx.^2 + a(1)*xx + a(2)*o2';
% n2 = p2' * (p2.*hh);
% p2 = p2/sqrt(n2);
% 
% b  = - [ xx.^3' * (p0.*hh) ; xx.^3' * (p1.*hh) ; xx.^3' * (p2.*hh) ];
% A  =   [ xx.^2'*(p0.*hh) xx'*(p0.*hh) o2*(p0.*hh)
%   xx.^2'*(p1.*hh) xx'*(p1.*hh) o2*(p1.*hh)
%   xx.^2'*(p2.*hh) xx'*(p2.*hh) o2*(p2.*hh) ];
% a  = A \ b;
% p3 = xx.^3 + a(1)*xx.^2 + a(2)*xx + a(3)*o2';
% n3 = p3' * (p3.*hh);
% p3 = p3/sqrt(n3);
% 
% A  = [ sqrt(1/2)*o2'.*hh p1.*hh p2.*hh p3.*hh ];

% compute orthogonal polynomials
h  = xx(2:end)-xx(1:end-1);
hh = 0.5*([h;0]+[0;h]);
p0 = sqrt(1/2)*o2'.*sqrt(hh);

b  = - (xx.*sqrt(hh))'  * p0;
A  =   (o2'.*sqrt(hh))' * p0;
a  = A \ b;
p1 = xx.*sqrt(hh) + a*o2'.*sqrt(hh);
n1 = p1' * p1;
p1 = p1/sqrt(n1);

b  = - [ (xx.^2.*sqrt(hh))' * p0 ; (xx.^2.*sqrt(hh))' * p1 ];
A  =   [ (xx.*sqrt(hh))'*p0 (o2'.*sqrt(hh))'*p0
  (xx.*sqrt(hh))'*p1 (o2'.*sqrt(hh))'*p1 ];
a  = A \ b;
p2 = xx.^2.*sqrt(hh) + a(1)*xx.*sqrt(hh) + a(2)*o2'.*sqrt(hh);
n2 = p2' * p2;
p2 = p2/sqrt(n2);

b  = - [ (xx.^3.*sqrt(hh))' * p0 ; (xx.^3.*sqrt(hh))' * p1 ; (xx.^3.*sqrt(hh))' * p2 ];
A  =   [ (xx.^2.*sqrt(hh))'*p0 (xx.*sqrt(hh))'*p0 (o2'.*sqrt(hh))'*p0
  (xx.^2.*sqrt(hh))'*p1 (xx.*sqrt(hh))'*p1 (o2'.*sqrt(hh))'*p1
  (xx.^2.*sqrt(hh))'*p2 (xx.*sqrt(hh))'*p2 (o2'.*sqrt(hh))'*p2 ];
a  = A \ b;
p3 = xx.^3.*sqrt(hh) + a(1)*xx.^2.*sqrt(hh) + a(2)*xx.*sqrt(hh) + a(3)*o2'.*sqrt(hh);
n3 = p3' * p3;
p3 = p3/sqrt(n3);

A  = [ p0 p1 p2 p3 ];

% A  = [o2' xx xx.^2 xx.^3];

C  = A\(YY'.*hh(:,o1));

ZZ2  = (A(:,1:3)*C(1:3,:))';
Res2 = YY-ZZ2;
Res2 = sqrt(sum(sum(Res2.^2,1))/(numel(o2)-1)); % standard deviation for sample

ResY = YY-ZZ2;
Res  = sum(sum(ResY.^2,1))/(numel(o2)-1);
% Rest = sqrt(1.5)*C(2,:)' - sqrt(0.875)*3*C(4,:)';
% Rest = Rest/norm(Rest) - t;
% Res  = Res + sum(sum(Rest.^2,1))/(numel(o2)-1);
end
