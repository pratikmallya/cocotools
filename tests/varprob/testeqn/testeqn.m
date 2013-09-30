N       = 200;
RR      = 20;
IR      = 5*pi;
ga      = 0.5;

re      = linspace(-RR,RR,N);
im      = linspace(-IR*1i,IR*1i,N);

[re im] = meshgrid(re,im);
la      = re + im;

A = real( (exp(la+conj(la))-1) ./ (la+conj(la)) );
% B = exp(la)+1;
% C = 3;
B = (exp(la)-1) ./ la;
C = 2;

[z1 z2] = solve_char_eqn(A,B,C);

K1      = char_it_DFDZ(A,B,C, ga, z1);
K2      = char_it_DFDZ(A,B,C, ga, z2);

ndz = abs(z1-z2);

zz1 = abs(z1);
zz2 = abs(z2);

% la = exp(la);

% zz1(abs(zz1)>=5) = nan;
% zz2(abs(zz2)>=5) = nan;
% 
% phi = linspace(-pi, pi, 100);
% ucx = cos(phi);
% ucy = sin(phi);
% ucz = 1.75*ones(size(phi));
% 
% figure(1)
% surf(real(la), imag(la), zz1, 'EdgeColor', 'none', ...
%   'FaceColor', 'interp') %, 'FaceAlpha', 0.9);
% hold on
% plot3(ucx, ucy, ucz, 'k-', 'linewidth', 2.0);
% plot3(ucx(1), ucy(1), ucz(1), 'ko', 'linewidth', 2.0, 'markersize', 8.0);
% hold off
% % axis([-2.2 2.2 -2.2 2.2 0 2.0])
% view(2)
% colorbar
% 
% figure(2)
% surf(real(la), imag(la), zz2, 'EdgeColor', 'none', ...
%   'FaceColor', 'interp') %, 'FaceAlpha', 0.8);
% hold on
% plot3(ucx, ucy, ucz*2, 'k-', 'linewidth', 2.0);
% plot3(ucx(1), ucy(1), ucz(1)*2, 'ko', 'linewidth', 2.0, 'markersize', 8.0);
% hold off
% % axis([-2.2 2.2 -2.2 2.2 0 4.0])
% view(2)
% colorbar

figure(1)
surf(real(la), imag(la), zz1, 'EdgeColor', 'none', ...
  'FaceColor', 'interp') %, 'FaceAlpha', 0.9);
hold on
surf(real(la), imag(la), zz2, 'EdgeColor', 'none', ...
  'FaceColor', 'interp') %, 'FaceAlpha', 0.8);
hold off
% axis([-2.2 2.2 -2.2 2.2 0 2.0])

figure(2)
surf(real(la), imag(la), zz1, K1, 'EdgeColor', 'none', ...
  'FaceColor', 'interp') %, 'FaceAlpha', 0.8);
% axis([-2.2 2.2 -2.2 2.2 0 4.0])

figure(3)
surf(real(la), imag(la), zz2, K2, 'EdgeColor', 'none', ...
  'FaceColor', 'interp') %, 'FaceAlpha', 0.8);
% axis([-2.2 2.2 -2.2 2.2 0 4.0])

% figure(3)
% surf(real(la), imag(la), real(z1), 'EdgeColor', 'interp', 'FaceColor', 'interp');
% hold on
% surf(real(la), imag(la), real(z2), 'EdgeColor', 'interp', 'FaceColor', 'interp');
% hold off
% 
% figure(4)
% surf(real(la), imag(la), imag(z1), 'EdgeColor', 'interp', 'FaceColor', 'interp');
% hold on
% surf(real(la), imag(la), imag(z2), 'EdgeColor', 'interp', 'FaceColor', 'interp');
% hold off

% figure(1)
