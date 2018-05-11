function [ I_normalized ] = image_normalization( I, I_flag )

if nargin == 1
    I_flag = true(size(I, 1), size(I, 2));
end

I_channel = reshape(I, size(I, 1)*size(I, 2), []);
I_flag_channel = reshape(I_flag, size(I, 1)*size(I, 2), []);

I_mean = mean(I_channel(I_flag_channel, :), 1);
I_centered = bsxfun(@minus, I_channel, I_mean);
I_centered(~I_flag_channel, :) = 0;

I_std = std(I_centered(I_flag_channel, :), 0, 1);
I_normalized = bsxfun(@rdivide, I_centered, I_std);
I_normalized = reshape(I_normalized, size(I));

end

