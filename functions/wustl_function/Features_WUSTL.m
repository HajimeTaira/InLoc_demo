function [ f, d ] = Features_WUSL( I_in )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% [f, d] = vl_covdet(I_in, 'Method', 'DoG', 'PeakThreshold', 0.013, 'EdgeThreshold', 10, ...
%     'EstimateAffineShape', false, 'EstimateOrientation', true, 'DoubleImage', false);%SIFT

[f, d] = vl_covdet(I_in, 'Method', 'DoG', 'PeakThreshold', 0.013, 'EdgeThreshold', 10, ...
    'EstimateAffineShape', true, 'EstimateOrientation', true, 'DoubleImage', false);%DoG+AA

end

