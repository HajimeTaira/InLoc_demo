 function [hash_table, hash_coarse] = at_dense_hashtable(cnnfeat1,cnnfeat1fine)

x_coarse_size = size(cnnfeat1,1);
y_coarse_size = size(cnnfeat1,2);

x_fine_size = size(cnnfeat1fine,1);
y_fine_size = size(cnnfeat1fine,2);

% scale = x_fine_size/x_coarse_size;
% if scale ~= whos  
%   error('aspect ratio should be preserved');
% end

% x_coarse_size = 5;
% y_coarse_size = 4;
% scale = 2;
% x_fine_size = x_coarse_size * scale;
% y_fine_size = y_coarse_size * scale;

% [x_coarse,y_coarse] = meshgrid(1:x_coarse_size,1:y_coarse_size);
hash_coarse = reshape(1:(x_coarse_size*y_coarse_size),x_coarse_size,y_coarse_size);

hash_fine = imresize(hash_coarse,[x_fine_size y_fine_size],'nearest');
[x_fine,y_fine] = meshgrid(1:y_fine_size,1:x_fine_size);

Nhash = max(hash_coarse(:));

hash_table = cell(1,Nhash);
hash_fine = hash_fine(:);
x_fine = x_fine(:);
y_fine = y_fine(:);
for ii=1:Nhash
  a = find(hash_fine == ii);
  hash_table{ii} = [x_fine(a)'; y_fine(a)'];
end
