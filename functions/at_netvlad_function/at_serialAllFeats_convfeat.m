%  Uses the network `net` to extract image representations from a list
%  of image filenames `imageFns`.
%  `imageFns` is a cell array containing image file names relative
%  to the `imPath` (i.e. `[imPath, imageFns{i}]` is a valid JPEG image).
%  The representations are saved to `outFn` (single 4-byte floats).
%
%  Additional options:
%
%  `useGPU': Use the GPU or not
%
%  `batchSize': The number of images to process in a batch. Note that if your
%       input images are not all of same size (they are in place recognition
%       datasets), you should set `batchSize` to 1.

function cnnfeat = at_serialAllFeats_convfeat(net, imPath, imageFns, varargin)

opts= struct(...
  'useGPU', true, ...
  'numThreads', 12, ...
  'batchSize', 1 ...
  );
opts= vl_argparse(opts, varargin);
simpleNnOpts= {'conserveMemory', false, 'mode', 'test'};

relja_display('cnn desciption: Start'); %tic

if opts.useGPU
  net= relja_simplenn_move(net, 'gpu');
else
  net= relja_simplenn_move(net, 'cpu');
end

thisImageFns= fullfile( imPath, imageFns );

ims = single(imread(thisImageFns));

% fix non-colour images
if size(ims,3)==1
  ims= cat(3,ims,ims,ims);
end

ims(:,:,1)= ims(:,:,1) - net.meta.normalization.averageImage(1,1,1);
ims(:,:,2)= ims(:,:,2) - net.meta.normalization.averageImage(1,1,2);
ims(:,:,3)= ims(:,:,3) - net.meta.normalization.averageImage(1,1,3);

ims = at_imageresize(ims);

if opts.useGPU
  ims= gpuArray(ims);
end

% isz = size(ims(:,:,1));
% if (1920*1440) < prod(isz)
%   ims = imresize(ims,sqrt((1920*1440)/prod(isz)));
% end

% ---------- extract features
res = vl_simplenn(net, ims, [], [], simpleNnOpts{:});
clear ims;

cnnfeat = cell(1,5);
cnnfeat{5}.x = gather(res(31).x);
cnnfeat{4}.x = gather(res(25).x);
cnnfeat{3}.x = gather(res(18).x);
cnnfeat{2}.x = gather(res(11).x);
cnnfeat{1}.x = gather(res(6).x);
clear res

relja_display('cnn desciption: End'); 
% fprintf(1,'%f\n',toc);

end
