clear all;
close all;

%% problem
%points
p3d = rand(3, 1000)*10;

figure();
scatter3(p3d(1, :), p3d(2, :), p3d(3, :), 'filled');axis equal; hold on;

%observe
Rp = [1, 0, 0; 0, 2^-0.5, -(2^-0.5); 0, 2^-0.5, 2^-0.5];
tp = - Rp * [5; 5; 5];
Pp = [Rp, tp];
p2d = bsxfun(@plus, Rp * p3d, tp);
observe_err = rand(3, 1000)*0.01;
observe_err = bsxfun(@minus, observe_err, mean(observe_err, 2)); 
p2d = p2d + observe_err;
p2d = bsxfun(@rdivide, p2d, sqrt(sum(p2d.^2, 1)));


figure();
scatter3(p2d(1, :), p2d(2, :), p2d(3, :), 'filled');axis equal; hold on;

%% solver

% %simple p3p
% Pe = P3PSolver([p2d(:, 1:3); p3d(:, 1:3)]);
% 
% %evaluation
% figure();
% for jj = 1:1:length(Pe)
% p3d_reproj = bsxfun(@plus, Pe{jj}(1:3, 1:3) * p3d, Pe{jj}(1:3, 4));
% p3d_reproj = bsxfun(@rdivide, p3d_reproj, sqrt(sum(p3d_reproj.^2, 1)));
% err = sqrt(sum((p2d - p3d_reproj).^2, 1));
% plot(err);hold on;
% end

%ransac
[ P, inls ] = ht_simple_ransac_p3p( p2d, p3d, 0.1*pi/180 );

%nonlinear optimization
[P_optim] = PnP_mex_wrapper( p2d(:, inls), p3d(:, inls), P );

%local optimization
[ lo_P, lo_inls ] = ht_lo_ransac_p3p( p2d, p3d, 0.1*pi/180 );

%evaluation
figure();
p3d_reproj = bsxfun(@plus, P(1:3, 1:3) * p3d, P(1:3, 4));
p3d_reproj = bsxfun(@rdivide, p3d_reproj, sqrt(sum(p3d_reproj.^2, 1)));
err = sqrt(sum((p2d - p3d_reproj).^2, 1));
plot(err);hold on;
p3d_reproj = bsxfun(@plus, P_optim(1:3, 1:3) * p3d, P_optim(1:3, 4));
p3d_reproj = bsxfun(@rdivide, p3d_reproj, sqrt(sum(p3d_reproj.^2, 1)));
err_optim = sqrt(sum((p2d - p3d_reproj).^2, 1));
plot(err_optim);hold on;
p3d_reproj = bsxfun(@plus, lo_P(1:3, 1:3) * p3d, lo_P(1:3, 4));
p3d_reproj = bsxfun(@rdivide, p3d_reproj, sqrt(sum(p3d_reproj.^2, 1)));
lo_err = sqrt(sum((p2d - p3d_reproj).^2, 1));
plot(lo_err);hold on;

sum(err)
sum(err_optim)
sum(lo_err)


