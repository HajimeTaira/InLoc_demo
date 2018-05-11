function [inliers, H, cell_inls] = at_denseransac(f1,f2,match,Nh)
if nargin < 4, Nh = 2; end;
% Repeat estimating at most Nh homograpies

% match = at_dense_tc(desc1,desc2);

% [x,y] = meshgrid(1:sz1(2),1:sz1(1));
% f1 = [y(:) x(:)]';
% [x,y] = meshgrid(1:sz2(2),1:sz2(1));
% f2 = [y(:) x(:)]';

% [u1,v1] = ind2sub(sz1(1:2),1:length(idx12));
% [u2,v2] = ind2sub(sz1(1:2),idx12);
% f1 = [u1; v1];
% f2 = [u2; v2];
% match = [1:length(idx12); 1:length(idx12)];

[ic, ia, ib] = unique(match','rows');
match = match(:,ia);

%--- ransacing
all_inliers = cell(1,Nh);
cell_inls = cell(1,Nh);
origindex = 1:size(match,2);
mt = match;
ii = 0;
H = cell(1,Nh);
while ii < Nh
  ii=ii+1;
  [H{ii}, inls] = at_ransacH4(f1(1:2,mt(1,:)), f2(1:2,mt(2,:)), 10000, 10, 1, .999);
%   [inls,H{ii}] = at_geometricVerification([f1; ones(1,size(f1,2))], [f2; ones(1,size(f2,2))], mt, ...
%     'tolerance1',10, 'tolerance2',5, 'tolerance3', 5);

  if length(inls) > 400 
    all_inliers{ii} = origindex(1,inls);
    mt(:,inls) = [];
    origindex(:,inls) = [];
    
    cell_inls{ii} = match(1:2,[all_inliers{ii}]);
  else
    break
  end
end
inliers = match(1:2,[all_inliers{:}]);


% u1i = u1(inliers(1,:)); v1i = v1(inliers(1,:));
% u2i = u2(inliers(2,:)); v2i = v2(inliers(2,:));
