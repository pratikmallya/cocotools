N       = 3000;
MM      = round(N*linspace(1,10,10)/20);
density = 0.1*linspace(1,10,10);
trials  = 25;

%% test with adding equations at top left
Times1 = zeros(numel(density), numel(MM));
Times2 = Times1;

for trial=1:trials
  fprintf('\n');
  for i = 1:numel(density)
    d  = density(i);
    % fprintf('density(A) = %.1f\n', d);
    ce = inf;
    while ce>1.0e+6
      A  = sprand(N,N, d);
      ce = condest(A);
      % fprintf('condest(A) = %.2e\n', ce);
    end
    b = rand(N,1);
    
    for j = 1:numel(MM)
      M       = MM(j);
      fprintf('trial %d, d = %.1f, M = %d, ', trial, d, M);
      [t1 t2] = time_linsolveA(M, N, A, b);
      Times1(i,j) = Times1(i,j) + t1;
      Times2(i,j) = Times2(i,j) + t2;
    end
  end
end

DimFac  = N./(N+repmat(MM, numel(density), 1));
factors = Times2./Times1  %#ok<NOPTS>

save 'timingsA' N MM density trials Times1 Times2 factors DimFac;

%% test with adding equations at bottom right
Times1 = zeros(numel(density), numel(MM));
Times2 = Times1;

for trial=1:trials
  fprintf('\n');
  for i = 1:numel(density)
    d  = density(i);
    % fprintf('density(A) = %.1f\n', d);
    ce = inf;
    while ce>1.0e+6
      A  = sprand(N,N, d);
      ce = condest(A);
      % fprintf('condest(A) = %.2e\n', ce);
    end
    b = rand(N,1);
    
    for j = 1:numel(MM)
      M       = MM(j);
      fprintf('trial %d, d = %.1f, M = %d, ', trial, d, M);
      [t1 t2] = time_linsolveB(M, N, A, b);
      Times1(i,j) = Times1(i,j) + t1;
      Times2(i,j) = Times2(i,j) + t2;
    end
  end
end

DimFac  = N./(N+repmat(MM, numel(density), 1));
factors = Times2./Times1  %#ok<NOPTS>

save 'timingsB' N MM density trials Times1 Times2 factors DimFac;
