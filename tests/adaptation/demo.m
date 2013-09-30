% gradient vectorfield of sum (x(i)-mean(x))^2
% x(i)' = mean(x)-x(i)
% J = [
%   -(N-1)/N 1/N ... 1/N
%    1/N   .          .
%     .        .      .
%     .            . 1/N
%    1/N ... 1/N -(N-1)/N
%   ]

f = @(t,x) - (1.0/3.0)*[
	 2*x(1)-x(2)-x(3)
	-x(1)+2*x(2)-x(3)
	-x(1)-x(2)+2*x(3)
	];

% ode45(f, [0 10], [5;10;1])
ode15s(f, [0 10], [5;10;1])
grid on
