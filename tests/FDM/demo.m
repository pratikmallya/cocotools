f = @(x,la) [
  exp(x(1,:).*x(2,:)) + la(1,:).*sin(x(2,:));
  x(1,:).^4 + la(2,:).*x(1,:).^2.*x(2,:).^2 + x(2,:).^3
  ];

fx = @(x,la) reshape([
  x(2,:).*exp(x(1,:).*x(2,:))
  4*x(1,:).^3 + 2*la(2,:).*x(1,:).*x(2,:).^2
  x(1,:).*exp(x(1,:).*x(2,:)) + la(1,:).*cos(x(2,:))
  2*la(2,:).*x(1,:).^2.*x(2,:) + 3*x(2,:).^2
  ], [2 2 size(x,2)]);

fxx = @(x,la) reshape([
  x(2,:).^2.*exp(x(1,:).*x(2,:))
  12*x(1,:).^2 + 2*la(2,:).*x(2,:).^2
  exp(x(1,:).*x(2,:)) + x(1,:).*x(2,:).*exp(x(1,:).*x(2,:))
  4*la(2,:).*x(1,:).*x(2,:)
  exp(x(1,:).*x(2,:)) + x(1,:).*x(2,:).*exp(x(1,:).*x(2,:))
  4*la(2,:).*x(1,:).*x(2,:)
  x(1,:).^2.*exp(x(1,:).*x(2,:)) - la(1,:).*sin(x(2,:))
  2*la(2,:).*x(1,:).^2 + 6*x(2,:)
  ], [2 2 2 size(x,2)]);

fla = @(x,la) reshape([
  sin(x(2,:))
  zeros(size(x(1,:)))
  zeros(size(x(1,:)))
  x(1,:).^2.*x(2,:).^2
  ], [2 2 size(x,2)]);

fxla = @(x,la) reshape([
  zeros(size(x(1,:)))
  zeros(size(x(1,:)))
  cos(x(2,:))
  zeros(size(x(1,:)))
  zeros(size(x(1,:)))
  2*x(1,:).*x(2,:).^2
  zeros(size(x(1,:)))
  2*x(1,:).^2.*x(2,:)
  ], [2 2 2 size(x,2)]);

N = 1000;

x = (rand-0.5)*(2.0e+1*rand)*rand(2,N);
p = (rand-0.5)*(1.0e+2*rand)*rand(2,N);
A = (rand-0.5)*(2.0e+2*rand)*rand(2,N,2);
[J JA JJA] = coco_num_D2FDX2(f, x, p, A);
[JP JPA] = coco_num_D2FDP2(f, x, p, [1 2], A);

FX  = fx  (x,p);
FXX = fxx (x,p);
FP  = fla (x,p);
FXP = fxla(x,p);

J2  = reshape(FX, [2 2*N]);
JP2 = [squeeze(FP(:,1,:)) squeeze(FP(:,2,:))];

JA2  = zeros(2,N,2);
JJA2 = zeros(2,2,N,2);
JPA2 = zeros(2,N,2,2);

for i=1:N
  JA2 (:,i,1)   = squeeze(FX (:,:,i))  *squeeze(A(:,i,1));
  JA2 (:,i,2)   = squeeze(FX (:,:,i))  *squeeze(A(:,i,2));
  
  JJA2(:,1,i,1) = squeeze(FXX(:,:,1,i))*squeeze(A(:,i,1));
  JJA2(:,2,i,1) = squeeze(FXX(:,:,2,i))*squeeze(A(:,i,1));
  JJA2(:,1,i,2) = squeeze(FXX(:,:,1,i))*squeeze(A(:,i,2));
  JJA2(:,2,i,2) = squeeze(FXX(:,:,2,i))*squeeze(A(:,i,2));
  
  JPA2(:,i,:,1) = squeeze(FXP(:,:,1,i))*squeeze(A(:,i,:));
  JPA2(:,i,:,2) = squeeze(FXP(:,:,2,i))*squeeze(A(:,i,:));
end
JA2  = reshape(JA2 , [2   N*2]);
JJA2 = reshape(JJA2, [2 2*N*2]);
JPA2 = reshape(JPA2, [2 2*N*2]);

merr = [max(max( abs(J-J2)./(1+abs(J2)) ))
  max(max( abs(JA-JA2)./(1+abs(JA2)) ))
  max(max( abs(JJA-JJA2)./(1+abs(JJA2)) ))
  max(max( abs(JP-JP2)./(1+abs(JP2)) ))
  max(max( abs(JPA-JPA2)./(1+abs(JPA2)) ))];

fprintf('max.rel.err: fx=%.2e, fx*A=%.2e, fxx*A=%.2e, fp=%.2e, fxp*A=%.2e\n', ...
  merr(1), merr(2), merr(3), merr(4), merr(5));
