clf;

m0 = 1;
la = 1+pi*1i;
si = 1;

m = m0;
mm = zeros(1,10);
for i=1:numel(mm)
  fprintf('iteration %d\n', i);
  si = 1/abs(m);
  m     = varit(m, la, si);
  mm(i) = m;
  plot(1:numel(mm), abs(mm),'o');
  drawnow
  pause(0.1)
end
