function [desc, f] = at_cnnfeat2vlfeat(x)

[u,v] = meshgrid(1:size(x,2),1:size(x,1));
f = [u(:)'; v(:)'];
desc1 = reshape(shiftdim(x(:)),size(x,1)*size(x,2),[])';

desc = yael_vecs_normalize(desc1);
