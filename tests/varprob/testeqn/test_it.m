N       = 101;
ItMX    = 500;
RR      = 20;
IR      = 5*pi;
eqn     = 2;

re      = linspace(-RR,RR,N);
im      = linspace(-IR*1i,IR*1i,N);

[re im] = meshgrid(re,im);
la      = re + im;

idx    = abs(real(la))<1.0e-8;
A      = real( (exp(la+conj(la))-1) ./ (la+conj(la)) );
A(idx) = 1;

switch eqn
  case 1
    B  = exp(la)+1;
    C  = 3;
    ga = 1/C;
    
  case 2
    idx    = abs(la)<1.0e-8;
    B      = (exp(la)-1) ./ la;
    B(idx) = 1;
    C      = 2;
    ga     = 1/C;

end

z0 = 3*ones(size(A));

for i=1:ItMX/10
  z  = iterat_char_eqn(A,B,C, ga, z0, 10);
  K  = char_it_DFDZ(A,B,C, ga, z);
  surf(real(la), imag(la), abs(z), K, 'EdgeColor', 'none', ...
    'FaceColor', 'interp', 'FaceAlpha', 1.0);
%   surf(real(la), imag(la), abs(z), abs(z-z0), 'EdgeColor', 'none', ...
%     'FaceColor', 'interp', 'FaceAlpha', 1.0);
  view([15 50])
  axis([-RR RR -IR IR 0 10]);
  drawnow
  z0 = z;
end
z2 = solve_char_eqn(A,B,C);

fprintf('||z-z*|| = % .2e, ||f(z)|| = % .2e, max(K) = % .2e\n', ...
  max(max(abs(z-z2))), ...
  max(max(abs(char_eqn(A,B,C, z)))), ...
  max(K(:)) )
