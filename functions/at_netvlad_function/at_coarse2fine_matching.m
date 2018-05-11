function [newmatch, feat1fine, feat2fine, cnnfeat1fine, cnnfeat2fine] = at_coarse2fine_matching(cnn1,cnn2,coarselayerlevel,finelayerlevel)

cnnfeat1 = cnn1{coarselayerlevel}.x;
cnnfeat2 = cnn2{coarselayerlevel}.x;

cnnfeat1fine = cnn1{finelayerlevel}.x;
cnnfeat2fine = cnn2{finelayerlevel}.x;

cnnfinesize1 = size(cnnfeat1fine(:,:,1));
cnnfinesize2 = size(cnnfeat2fine(:,:,1));

[desc1, feat1] = at_cnnfeat2vlfeat(cnnfeat1);
[desc2, feat2] = at_cnnfeat2vlfeat(cnnfeat2);

[desc1fine, feat1fine] = at_cnnfeat2vlfeat(cnnfeat1fine);
[desc2fine, feat2fine] = at_cnnfeat2vlfeat(cnnfeat2fine);

match12 = at_dense_tc(desc1,desc2);

% fine level position is

[hash_table1, hash_coarse1] = at_dense_hashtable(cnnfeat1,cnnfeat1fine);
[hash_table2, hash_coarse2] = at_dense_hashtable(cnnfeat2,cnnfeat2fine);

newmatch = cell(1,size(match12,2));
for ii=1:size(match12,2)
  [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1(:,match12(1,ii)),desc1fine,feat1fine,cnnfinesize1);
  [d2,f2,ind2] = at_retrieve_fineposition(hash_coarse2,hash_table2,feat2(:,match12(2,ii)),desc2fine,feat2fine,cnnfinesize2);  
  thismatch12 = at_dense_tc(d1,d2);  
  newmatch{ii} = [ind1(thismatch12(1,:)); ind2(thismatch12(2,:))];  
end
newmatch = [newmatch{:}];


% %--- compute similarity (matching NN score)
% % [match12,inls12] = at_denseransac(desc1,f1,desc2,f2);
%

function [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1,desc1fine,feat1fine,sizeF)

x = feat1(2,:);
y = feat1(1,:);

xmin = max(1,x-1);
%xmin = max(1,x);
xmax = min(size(hash_coarse1,1),x+1);
ymin = max(1,y-1);
%ymin = max(1,y);
ymax = min(size(hash_coarse1,2),y+1);

[x_nb,y_nb] = meshgrid(xmin:xmax,ymin:ymax);
x_nb = x_nb(:); y_nb = y_nb(:); 

pos1 = hash_coarse1(x_nb,y_nb);
sub1 = [hash_table1{pos1}];
ind1 = sub2ind(sizeF,sub1(2,:),sub1(1,:));

d1 = desc1fine(:,ind1);
f1 = feat1fine(:,ind1);
