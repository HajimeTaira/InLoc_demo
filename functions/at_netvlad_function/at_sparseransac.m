function [match, inliers, H, cell_inls] = at_sparseransac(f1,desc1,f2,desc2,Nh,minInliers)
% Run geometric verification Nh times as long as it gets more than minInliers 
% inlier matches. 
%
% % Each homography and its supports (inliers) are stored in H and cell_inls in cell format. 
% % You can map points in image 1 to image 2, e.g. 
% x1 = f1(1:2,cell_inls{1}(1,:));
% y = H{1}\[x1; ones(1,size(x1,2))];
% p12 = [y(1,:)./y(3,:); y(2,:)./y(3,:)];
% % Then, you can measure discrepancy by 
% x2 = f2(1:2,cell_inls{1}(2,:));
% d = sqrt(sum((x2-p12).^2,1));
%
% match: tentative matches
% inliers: concatenation of cell_inls
%
% Author: Akihiko Torii (torii@ctrl.titech.ac.jp)

if nargin < 3, Nh = 1; end;
if nargin < 4, minInliers = 20; end;
   
match = []; inliers = zeros(2, 0); H = []; cell_inls = [];
if size(f1,2) < minInliers || size(f2,2) < minInliers
  return;
end

[idx12, dis12] = yael_nn(single(desc2), single(desc1), 2);
% match = [double(1:size(idx12,2)); double(idx12(1,:)); dis12];
% match = match(:,(dis12(1,:)./dis12(2,:))<0.9^2);

% % If you want to make tentative matches more convervatively, 
% % try below. This takes mutually nearest matches only. 
% 
Ndesc = size(f1,2);
[idx21, dis21] = yael_nn(single(desc1), single(desc2), 2);
match = NaN(3,Ndesc);
for ii=1:Ndesc
  if ~isnan(idx12(1,ii))
    if idx21(1,idx12(1,ii)) == ii
      match(:,ii) = [ii; double(idx12(1,ii)); dis12(1,ii)];
    end
  end
end
match = match(:,~isnan(match(1,:)));

rng(43);


%--- ransacing
all_inliers = cell(1,Nh);
cell_inls = cell(1,Nh);
H = cell(1,Nh);
origindex = 1:size(match,2);
mt = match;
ii = 0;
while ii<Nh && length(mt)>minInliers
  ii=ii+1;
  [inls,H{ii}] = geometricVerification(f1, f2, mt, 'numRefinementIterations', 6);
   %'tolerance1',10,'tolerance2',8,'tolerance3',4,...     
  if length(inls) > minInliers
    all_inliers{ii} = origindex(1,inls);
    mt(:,inls) = [];
    origindex(:,inls) = [];    
    cell_inls{ii} = match(1:2,[all_inliers{ii}]);
  else
    break
  end;
end
inliers = match(1:2,[all_inliers{:}]);
