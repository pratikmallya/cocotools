clf;

m0 = 1;
N   = 151;
re  = linspace(-10,10,N);
im  = linspace(-5i*pi,5i*pi,N);

[re im] = meshgrid(re,im);
la      = re + im;

mm = zeros(size(la));
co = mm;

for i=1:size(la,1)
  for j=1:size(la,2)
    m  = m0;
    m1 = m0;
    for k=1:501
      % si = 1;
      % si = 6/abs(m);
      si = 6/(1+abs(m));
      m1 = m;
      m  = varit(m, la(i,j), si);
      if abs(m1-m)<1.0e-12
        break
      end
    end
    mm(i,j) = abs(m);
    %co(i,j) = abs(m1-m);
    co(i,j) = k;
  end
end

max(max(co))
min(min(co))
sum(sum(co))/numel(co)

surf(real(la), imag(la), mm, co, 'EdgeColor', 'none', ...
  'FaceColor', 'interp', 'FaceAlpha', 1.0);
