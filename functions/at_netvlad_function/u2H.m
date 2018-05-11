function H = u2H(us)

A1    = normu(us(1:3,:));
A2    = normu(us(4:6,:));
   
u1   = A1*us(1:3,:); 
u2   = A2*us(4:6,:); 

us = [u1;u2];

Z1        = us(4:6,:)' .* (us(3,:)' * [1,1,1]);
Z1(:,4:6) = 0;
Z1(:,7:9) = -us(4:6,:)'.* (us(1,:)' * [1,1,1]);

Z2(:,4:6) = us(4:6,:)' .* (us(3,:)' * [1,1,1]);
Z2(:,1:3) = 0;
Z2(:,7:9) = -us(4:6,:)' .* (us(2,:)' * [1,1,1]);

Z = [Z1; Z2];

if any(isnan(Z(:))), H = eye(3); return; end;
if any(isinf(Z(:))), H = eye(3); return; end;

[U,D,V] = svd(Z);
H = reshape(V(:,9),3,3)';
H = A1\H*A2;

function A = normu(u);

% NORMU Normalizes image points to be used for LS estimation.
%       A = NORMU(u) finds normalization matrix A so that mean(A*u)=0 and mean(||A*u||)=sqrt(2).
%       (see Hartley: In Defence of 8-point Algorithm, ICCV`95).
%       Parameters:
%         u ... Size (2,N) or (3,N). Points to normalize.
%         A ... Size (3,3). Normalization matrix.

if size(u,1)==3, u = p2e(u); end

m = mean(u,2); % <=> mean (u,2)
u = u - m*ones(1,size(u,2));
distu = sqrt(sum(u.*u));
r = mean(distu)/sqrt(2);
A  = diag([1/r 1/r 1]);
A(1:2,3) = -m/r;

function e = p2e (u)
e = u(1:2,:) ./ ([1;1] * u(3,:));
